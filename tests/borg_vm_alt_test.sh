#!/usr/bin/env bash

set -u

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
launcher="$project_root/_statica/bin/function/borg_vm_alt.sh"
failures=0

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    failures=$((failures + 1))
}

assert_contains() {
    local file=$1 text=$2 message=$3
    grep -Fq -- "$text" "$file" || fail "$message"
}

assert_not_contains() {
    local file=$1 text=$2 message=$3
    if grep -Fq -- "$text" "$file"; then
        fail "$message"
    fi
}

run_vm() (
    local root=$1
    export BORG_VM_ALT_BASE_DIR="$root/base"
    export BORG_VM_ALT_BRIDGE_CONF="$root/bridge.conf"
    export BORG_VM_ALT_PULSE_SERVER="$root/pulse/native"
    export BORG_VM_ALT_ROUTE_WAIT_ATTEMPTS=1
    export MOCK_LOG="$root/commands.log"
    : >"$MOCK_LOG"

    # These mocks are invoked indirectly by the sourced launcher.
    # shellcheck disable=SC2329
    qemu-img() {
        {
            printf 'qemu-img'
            printf ' <%s>' "$@"
            printf '\n'
        } >>"$MOCK_LOG"
        : >"${4}"
    }

    # shellcheck disable=SC2329
    qemu-system-x86_64() {
        {
            printf 'qemu-system-x86_64'
            printf ' <%s>' "$@"
            printf '\n'
        } >>"$MOCK_LOG"
    }

    # shellcheck disable=SC2329
    nmcli() {
        {
            printf 'nmcli'
            printf ' <%s>' "$@"
            printf '\n'
        } >>"$MOCK_LOG"

        if [[ "$*" == '-t -f NAME,TYPE connection show' ]]; then
            [[ ${MOCK_BRIDGE_PRESENT:-0} == 1 ]] && printf 'br-alt:bridge\n'
            return 0
        fi
        if [[ "$*" == '-g connection.master connection show br-alt-enp1s0' ]]; then
            [[ ${MOCK_BRIDGE_INVALID:-0} == 1 ]] || printf 'br-alt\n'
            return 0
        fi
        if [[ "$*" == '-g connection.interface-name connection show br-alt-enp1s0' ]]; then
            printf 'enp1s0\n'
            return 0
        fi
        if [[ "$*" == '-t -f NAME,DEVICE connection show --active' ]]; then
            printf 'br-alt:br-alt\nbr-alt-enp1s0:enp1s0\n'
            return 0
        fi
        if [[ "$*" == '-g GENERAL.CONNECTION device show enp1s0' ]]; then
            printf 'Wired connection 1\n'
            return 0
        fi
        [[ ${MOCK_NMCLI_FAIL:-0} == 1 ]] && return 1
        return 0
    }

    # shellcheck disable=SC2329
    ip() {
        {
            printf 'ip'
            printf ' <%s>' "$@"
            printf '\n'
        } >>"$MOCK_LOG"
        if [[ "$*" == 'route show default dev br-alt' ]]; then
            [[ ${MOCK_ROUTE_FAIL:-0} == 1 ]] || printf 'default via 192.168.1.254 dev br-alt\n'
            return 0
        fi
        [[ "$*" == link\ show* ]] && return 1
        return 0
    }

    # shellcheck disable=SC2329
    sudo() {
        {
            printf 'sudo'
            printf ' <%s>' "$@"
            printf '\n'
        } >>"$MOCK_LOG"
        "$@"
    }

    export -f qemu-img qemu-system-x86_64 nmcli ip sudo
    # shellcheck source=/dev/null
    source "$launcher"
    borg_vm_alt
)

test_public_function_exists() {
    # shellcheck source=/dev/null
    source "$launcher"
    declare -F borg_vm_alt >/dev/null || fail 'launcher must define borg_vm_alt'
}

test_launcher_defines_only_one_vm_function() {
    local functions
    functions=$(bash -c 'source "$1"; compgen -A function | grep -E "^_?borg_vm_alt" | sort' _ "$launcher")
    [[ "$functions" == 'borg_vm_alt' ]] || fail 'launcher must define only the borg_vm_alt function'
}

test_installed_vm_does_not_require_or_attach_iso() {
    local root
    root=$(mktemp -d)
    mkdir -p "$root/base/share" "$root/pulse"
    : >"$root/pulse/native"
    run_vm "$root" >"$root/out" 2>&1 || fail 'installed VM must start without an ISO file'
    assert_not_contains "$root/commands.log" '<-cdrom>' 'installed VM must not attach a CD-ROM'
    assert_not_contains "$root/commands.log" 'alt.11.kde.iso' 'installed VM must not reference the installer ISO'
    assert_contains "$root/commands.log" '<-boot> <order=c,menu=on>' 'installed VM must always boot from its disk'
}

test_first_run_creates_50g_vmdk_and_launches_complete_vm() {
    local root log
    root=$(mktemp -d)
    mkdir -p "$root/base/share" "$root/pulse"
    : >"$root/base/alt.11.kde.iso"
    : >"$root/pulse/native"
    log="$root/commands.log"

    run_vm "$root" >"$root/out" 2>&1 || fail 'valid first run must succeed'
    assert_contains "$log" "qemu-img <create> <-f> <vmdk> <$root/base/alt-linux.vmdk> <50G>" 'first run must create a 50G VMDK'
    assert_contains "$log" '<file='"$root/base/alt-linux.vmdk"',format=vmdk,if=virtio,cache=writeback>' 'QEMU must attach the VMDK as a VirtIO disk'
    assert_not_contains "$log" '<-cdrom>' 'QEMU must not attach the ALT installer ISO after installation'
    assert_contains "$log" '<tap,id=net0,ifname=tap-alt-' 'QEMU must use the prepared bridged TAP device'
    assert_contains "$log" 'sudo <nmcli> <connection> <up> <br-alt-enp1s0>' 'first setup must activate the bridged Ethernet profile'
    assert_contains "$log" '<virtio-net-pci,netdev=net0,mac=52:54:00:41:4c:54>' 'QEMU must expose a stable independent MAC address'
    assert_contains "$log" 'mount_tag=hostshare' 'QEMU must expose the shared directory with mount tag hostshare'
    assert_contains "$log" '<-audiodev> <pa,id=audio0,server='"$root/pulse/native"'>' 'QEMU must use the configured PulseAudio server'
    assert_contains "$log" '<-device> <intel-hda>' 'QEMU must include an HDA controller'
    assert_contains "$log" '<-device> <hda-duplex,audiodev=audio0>' 'QEMU must include duplex sound'
    assert_contains "$log" '<-display> <spice-app>' 'QEMU must use the SPICE application display'
    assert_contains "$log" '<-device> <qemu-xhci,id=xhci>' 'QEMU must include a USB 3 controller'
    assert_contains "$log" '<-device> <usb-redir,chardev=usbredirchardev3,id=usbredirdev3>' 'QEMU must provide three hot-plug USB redirection channels'
    assert_contains "$log" 'sudo <ip> <tuntap> <add>' 'launcher must create a user-owned TAP with narrowly scoped sudo'
    assert_contains "$log" 'sudo <ip> <link> <delete>' 'launcher must delete the TAP after QEMU exits'
}

test_existing_disk_is_preserved() {
    local root log
    root=$(mktemp -d)
    mkdir -p "$root/base/share" "$root/pulse"
    printf 'keep-me' >"$root/base/alt-linux.vmdk"
    : >"$root/base/alt.11.kde.iso"
    : >"$root/pulse/native"
    printf 'allow br-alt\n' >"$root/bridge.conf"
    export MOCK_BRIDGE_PRESENT=1
    run_vm "$root" >"$root/out" 2>&1 || fail 'run with existing disk must succeed'
    unset MOCK_BRIDGE_PRESENT
    log="$root/commands.log"
    assert_not_contains "$log" 'qemu-img' 'existing disk must not be recreated'
    [[ $(<"$root/base/alt-linux.vmdk") == 'keep-me' ]] || fail 'existing disk contents must be preserved'
    assert_not_contains "$log" 'sudo <nmcli>' 'existing valid bridge must not trigger privileged NetworkManager configuration'
}

test_bridge_failure_stops_launch() {
    local root log
    root=$(mktemp -d)
    mkdir -p "$root/base/share" "$root/pulse"
    : >"$root/base/alt.11.kde.iso"
    : >"$root/pulse/native"
    export MOCK_NMCLI_FAIL=1
    if run_vm "$root" >"$root/out" 2>&1; then
        fail 'bridge setup failure must return failure'
    fi
    unset MOCK_NMCLI_FAIL
    log="$root/commands.log"
    assert_not_contains "$log" 'qemu-system-x86_64' 'bridge setup failure must stop before QEMU launch'
}

test_partial_saved_bridge_is_rejected() {
    local root log
    root=$(mktemp -d)
    mkdir -p "$root/base/share" "$root/pulse"
    : >"$root/base/alt.11.kde.iso"
    : >"$root/pulse/native"
    export MOCK_BRIDGE_PRESENT=1 MOCK_BRIDGE_INVALID=1
    if run_vm "$root" >"$root/out" 2>&1; then
        fail 'partial saved bridge must return failure'
    fi
    unset MOCK_BRIDGE_PRESENT MOCK_BRIDGE_INVALID
    log="$root/commands.log"
    assert_not_contains "$log" 'qemu-system-x86_64' 'partial bridge must stop before QEMU launch'
    assert_not_contains "$log" 'sudo' 'partial bridge must not be mutated automatically'
}

test_failed_route_recovery_restores_original_connection() {
    local root log
    root=$(mktemp -d)
    mkdir -p "$root/base/share" "$root/pulse"
    : >"$root/base/alt.11.kde.iso"
    : >"$root/pulse/native"
    export MOCK_ROUTE_FAIL=1
    if run_vm "$root" >"$root/out" 2>&1; then
        fail 'missing default route after migration must return failure'
    fi
    unset MOCK_ROUTE_FAIL
    log="$root/commands.log"
    assert_contains "$log" 'sudo <nmcli> <connection> <up> <Wired connection 1>' 'route failure must restore the original wired connection'
    assert_not_contains "$log" 'qemu-system-x86_64' 'route failure must stop before QEMU launch'
}

test_lock_prevents_concurrent_disk_creation() {
    local root log
    root=$(mktemp -d)
    mkdir -p "$root/base/share" "$root/pulse"
    : >"$root/base/alt.11.kde.iso"
    : >"$root/pulse/native"
    exec 8>"$root/base/.borg_vm_alt.lock"
    flock -n 8 || fail 'test must acquire VM lock'
    if run_vm "$root" >"$root/out" 2>&1; then
        fail 'concurrent VM invocation must return failure'
    fi
    flock -u 8
    exec 8>&-
    log="$root/commands.log"
    assert_not_contains "$log" 'qemu-img' 'locked invocation must not create or recreate the disk'
    assert_not_contains "$log" 'qemu-system-x86_64' 'locked invocation must not start QEMU'
}

test_public_function_exists
test_launcher_defines_only_one_vm_function
test_installed_vm_does_not_require_or_attach_iso
test_first_run_creates_50g_vmdk_and_launches_complete_vm
test_existing_disk_is_preserved
test_bridge_failure_stops_launch
test_partial_saved_bridge_is_rejected
test_failed_route_recovery_restores_original_connection
test_lock_prevents_concurrent_disk_creation

if ((failures > 0)); then
    printf '%d test assertion(s) failed\n' "$failures" >&2
    exit 1
fi

printf 'PASS: borg_vm_alt launcher tests\n'
