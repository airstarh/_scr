#!/usr/bin/env bash
# Read-only DNS diagnostics for Kubuntu / NetworkManager / systemd-resolved.
# Usage: ./diag.dns.sh [hostname]
# No sudo, configuration changes, or subnet scanning.
set -uo pipefail
export LC_ALL=C
export SYSTEMD_PAGER=cat
export PAGER=cat
domain=${1:-azo.zadobro.crazedns.ru}
if (( $# > 1 )) || [[ ! $domain =~ ^[[:alnum:]][[:alnum:]._-]*$ ]]; then
    printf 'Usage: %s [hostname]\n' "$0" >&2
    exit 2
fi
section() { printf '\n=== %s ===\n' "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }
declare -A seen=()
declare -a servers=()
add_server() {
    local addr=$1
    [[ $addr == *.* || $addr == *:* ]] || return 0
    if [[ ! ${seen[$addr]+present} ]]; then
        seen[$addr]=1
        servers+=("$addr")
    fi
}
section 'Time and system'
date --iso-8601=seconds
printf 'Host: %s\nQuery hostname: %s\n' "$(hostname)" "$domain"
if [[ -r /etc/os-release ]]; then
    sed -n '/^PRETTY_NAME=/p' /etc/os-release
fi
section 'Active resolver: current server and per-interface DNS'
if have resolvectl; then
    resolvectl --no-pager status || printf 'Could not read systemd-resolved status.\n'
    if dns_lines=$(resolvectl dns 2>/dev/null); then
        while IFS= read -r line; do
            addresses=${line#*:}
            for addr in $addresses; do add_server "$addr"; done
        done <<< "$dns_lines"
    fi
else
    printf 'resolvectl is not installed.\n'
fi
section 'NetworkManager: DNS and DHCP data on all devices'
if have nmcli; then
    nmcli -f GENERAL.DEVICE,GENERAL.CONNECTION,GENERAL.STATE,IP4.DNS,IP4.GATEWAY,IP6.DNS,IP6.GATEWAY,DHCP4.OPTION,DHCP6.OPTION device show || true
    if dns_lines=$(nmcli -t -f GENERAL.DEVICE,IP4.DNS,IP6.DNS device show 2>/dev/null); then
        device=''
        while IFS= read -r line; do
            case "$line" in
                GENERAL.DEVICE:*) device=${line#*:} ;;
                IP4.DNS*:*|IP6.DNS*:*)
                    addr=${line#*:}
                    addr=${addr//\\:/:}
                    if [[ $addr == [fF][eE]80:* && $addr != *%* && -n $device ]]; then
                        addr+="%$device"
                    fi
                    [[ -z $addr || $addr == -- ]] || add_server "$addr"
                    ;;
            esac
        done <<< "$dns_lines"
    fi
else
    printf 'nmcli is not installed.\n'
fi
section '/etc/resolv.conf (may list a local stub rather than upstream servers)'
readlink -f /etc/resolv.conf || true
if [[ -r /etc/resolv.conf ]]; then
    cat /etc/resolv.conf
    while read -r keyword addr rest; do
        [[ $keyword != nameserver || -z ${addr:-} ]] || add_server "$addr"
    done < /etc/resolv.conf
fi
section 'Routing'
if have ip; then
    ip -4 route show default || true
    ip -6 route show default || true
fi
section 'Configured DNS addresses (deduplicated)'
if (( ${#servers[@]} )); then
    printf '%s\n' "${servers[@]}"
else
    printf 'No DNS addresses detected; the network may not be ready yet.\n'
fi
section 'Resolution through the system resolver (includes /etc/hosts)'
if have getent; then
    if have timeout; then
        timeout 10s getent ahosts "$domain" || printf 'No result or lookup timed out.\n'
    else
        printf 'timeout unavailable; skipping potentially blocking system lookup.\n'
    fi
fi
section 'Direct DNS tests: UDP and TCP, A and AAAA'
if have dig; then
    for addr in "${servers[@]}"; do
        for transport in UDP TCP; do
            extra=()
            [[ $transport != TCP ]] || extra+=(+tcp)
            for record in A AAAA; do
                printf '\n--- Server %s | %s | %s ---\n' "$addr" "$transport" "$record"
                dig "@$addr" "$domain" "$record" +time=2 +tries=1 +noall +comments +answer +stats "${extra[@]}" || true
            done
        done
    done
else
    printf 'dig is missing. To enable server tests: sudo apt install dnsutils\n'
fi
section 'How to read this report'
printf '%s\n' \
    'Current DNS Server = server selected by systemd-resolved for that interface.' \
    'DHCP domain_name_servers = addresses supplied by your router/DHCP server.' \
    '127.0.0.53 or another loopback address = local resolver, not an external DNS server.' \
    'NOERROR = query answered; an empty AAAA answer can simply mean no IPv6 record.' \
    'REFUSED / SERVFAIL / timeout = server did not resolve this query successfully.' \
    'Direct tests bypass system cache and /etc/hosts; split-DNS/VPN policy may differ.' \
    'This reports OS-configured servers, not every DNS server on the LAN.' \
    'Browser Secure DNS, containers, and application-specific resolvers can differ.'
