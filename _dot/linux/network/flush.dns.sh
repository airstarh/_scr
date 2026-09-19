#!/usr/bin/env bash

# Flush the local DNS cache without restarting networking or renewing DHCP.
# Supports the DNS cache implementations most commonly found on Linux.

set -u

run_privileged() {
    if (( EUID == 0 )); then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        printf 'Administrative privileges are required to run: %s\n' "$*" >&2
        return 1
    fi
}

if command -v resolvectl >/dev/null 2>&1; then
    if resolvectl flush-caches; then
        printf 'DNS cache flushed with resolvectl.\n'
        exit 0
    fi
fi

if command -v systemd-resolve >/dev/null 2>&1; then
    if systemd-resolve --flush-caches; then
        printf 'DNS cache flushed with systemd-resolve.\n'
        exit 0
    fi
fi

if command -v nscd >/dev/null 2>&1; then
    if run_privileged nscd -i hosts; then
        printf 'DNS cache flushed with nscd.\n'
        exit 0
    fi
fi

if command -v rndc >/dev/null 2>&1; then
    if run_privileged rndc flush; then
        printf 'DNS cache flushed with rndc.\n'
        exit 0
    fi
fi

if command -v dnsmasq >/dev/null 2>&1 && command -v pkill >/dev/null 2>&1; then
    # SIGHUP clears dnsmasq's cache without stopping the daemon.
    if run_privileged pkill -HUP -x dnsmasq; then
        printf 'DNS cache flushed by signalling dnsmasq.\n'
        exit 0
    fi
fi

printf 'No supported local DNS cache could be flushed.\n' >&2
printf 'Supported tools: resolvectl, systemd-resolve, nscd, rndc, dnsmasq.\n' >&2
exit 1
