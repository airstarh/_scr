#!/usr/bin/env bash

borg_vm_alt() (
    local base_dir=${BORG_VM_ALT_BASE_DIR:-/mnt/d501aaa/_v/qemu_alt}
    local disk="$base_dir/alt-linux.vmdk"
    local share="$base_dir/share"
    local pulse_server=${BORG_VM_ALT_PULSE_SERVER:-/run/user/${UID}/pulse/native}
    local tap_name="tap-alt-${UID}"
    local connections original_connection master interface active
    local attempts=${BORG_VM_ALT_ROUTE_WAIT_ATTEMPTS:-15}
    local attempt command_name qemu_status

    [[ -d "$share" ]] || {
        printf 'borg_vm_alt: shared directory not found: %s\n' "$share" >&2
        return 1
    }
    [[ -S "$pulse_server" || -e "$pulse_server" ]] || {
        printf 'borg_vm_alt: PulseAudio socket not found: %s\n' "$pulse_server" >&2
        return 1
    }

    for command_name in qemu-img qemu-system-x86_64 nmcli sudo ip flock; do
        command -v "$command_name" >/dev/null 2>&1 || {
            printf 'borg_vm_alt: required command not found: %s\n' "$command_name" >&2
            return 1
        }
    done

    exec 9>"$base_dir/.borg_vm_alt.lock" || {
        printf 'borg_vm_alt: could not open the VM lock file\n' >&2
        return 1
    }
    flock -n 9 || {
        printf 'borg_vm_alt: another borg_vm_alt instance is already running\n' >&2
        return 1
    }

    if [[ ! -e "$disk" ]]; then
        printf 'Creating portable 50 GB VMDK: %s\n' "$disk" >&2
        qemu-img create -f vmdk "$disk" 50G || {
            printf 'borg_vm_alt: VMDK creation failed\n' >&2
            return 1
        }
    elif [[ ! -f "$disk" ]]; then
        printf 'borg_vm_alt: disk path exists but is not a regular file: %s\n' "$disk" >&2
        return 1
    fi

    connections=$(nmcli -t -f NAME,TYPE connection show) || {
        printf 'borg_vm_alt: could not inspect NetworkManager connections\n' >&2
        return 1
    }

    if grep -Fxq 'br-alt:bridge' <<<"$connections"; then
        master=$(nmcli -g connection.master connection show br-alt-enp1s0 2>/dev/null) || master=
        interface=$(nmcli -g connection.interface-name connection show br-alt-enp1s0 2>/dev/null) || interface=
        active=$(nmcli -t -f NAME,DEVICE connection show --active) || active=

        if [[ "$master" != br-alt || "$interface" != enp1s0 ]] ||
            ! grep -Fxq 'br-alt:br-alt' <<<"$active" ||
            ! grep -Fxq 'br-alt-enp1s0:enp1s0' <<<"$active" ||
            ! ip route show default dev br-alt | grep -q '^default '; then
            printf 'borg_vm_alt: saved br-alt configuration is incomplete, inactive, or has no default route\n' >&2
            printf 'borg_vm_alt: repair or remove br-alt and br-alt-enp1s0 with NetworkManager before retrying\n' >&2
            return 1
        fi
    else
        original_connection=$(nmcli -g GENERAL.CONNECTION device show enp1s0) || {
            printf 'borg_vm_alt: could not identify the current wired connection\n' >&2
            return 1
        }

        printf 'borg_vm_alt: creating persistent LAN bridge br-alt over enp1s0 (sudo required)\n' >&2
        printf 'borg_vm_alt: the wired connection may be interrupted briefly during first-time setup\n' >&2

        if ! sudo nmcli connection add type bridge ifname br-alt con-name br-alt \
            ipv4.method auto ipv6.method auto bridge.stp no; then
            [[ -z "$original_connection" || "$original_connection" == '--' ]] || \
                sudo nmcli connection up "$original_connection"
            return 1
        fi

        if ! sudo nmcli connection add type ethernet ifname enp1s0 \
            con-name br-alt-enp1s0 master br-alt; then
            [[ -z "$original_connection" || "$original_connection" == '--' ]] || \
                sudo nmcli connection up "$original_connection"
            return 1
        fi

        if ! sudo nmcli connection up br-alt || ! sudo nmcli connection up br-alt-enp1s0; then
            [[ -z "$original_connection" || "$original_connection" == '--' ]] || \
                sudo nmcli connection up "$original_connection"
            return 1
        fi

        for ((attempt = 1; attempt <= attempts; attempt++)); do
            ip route show default dev br-alt | grep -q '^default ' && break
            ((attempt < attempts)) && sleep 1
        done

        if ! ip route show default dev br-alt | grep -q '^default '; then
            printf 'borg_vm_alt: br-alt did not obtain a default route in time\n' >&2
            if [[ -n "$original_connection" && "$original_connection" != '--' ]]; then
                printf 'borg_vm_alt: restoring previous wired connection: %s\n' "$original_connection" >&2
                sudo nmcli connection up "$original_connection"
            fi
            return 1
        fi
    fi

    if ip link show dev "$tap_name" >/dev/null 2>&1; then
        printf 'borg_vm_alt: TAP device already exists: %s\n' "$tap_name" >&2
        return 1
    fi

    sudo ip tuntap add dev "$tap_name" mode tap user "$UID" || return 1
    if ! sudo ip link set dev "$tap_name" master br-alt || ! sudo ip link set dev "$tap_name" up; then
        sudo ip link delete dev "$tap_name" >/dev/null 2>&1 || true
        printf 'borg_vm_alt: TAP setup failed; QEMU was not started\n' >&2
        return 1
    fi

    printf 'Starting ALT Linux VM. Shared-folder mount tag: hostshare\n' >&2
    printf 'Use the SPICE USB menu to redirect an inserted flash drive.\n' >&2

    qemu-system-x86_64 \
        -name alt-linux \
        -enable-kvm \
        -machine type=q35 \
        -cpu host \
        -smp cores=2,threads=2,sockets=1 \
        -m 4096 \
        -drive "file=$disk,format=vmdk,if=virtio,cache=writeback" \
        -boot order=c,menu=on \
        -netdev "tap,id=net0,ifname=$tap_name,script=no,downscript=no" \
        -device virtio-net-pci,netdev=net0,mac=52:54:00:41:4c:54 \
        -virtfs "local,id=hostshare,path=$share,security_model=mapped-xattr,mount_tag=hostshare" \
        -device virtio-vga-gl \
        -audiodev "pa,id=audio0,server=$pulse_server" \
        -device intel-hda \
        -device hda-duplex,audiodev=audio0 \
        -device virtio-serial-pci,id=virtio-serial0 \
        -chardev spicevmc,id=vdagent,name=vdagent \
        -device virtserialport,chardev=vdagent,name=com.redhat.spice.0 \
        -device qemu-xhci,id=xhci \
        -chardev spicevmc,name=usbredir,id=usbredirchardev1 \
        -device usb-redir,chardev=usbredirchardev1,id=usbredirdev1 \
        -chardev spicevmc,name=usbredir,id=usbredirchardev2 \
        -device usb-redir,chardev=usbredirchardev2,id=usbredirdev2 \
        -chardev spicevmc,name=usbredir,id=usbredirchardev3 \
        -device usb-redir,chardev=usbredirchardev3,id=usbredirdev3 \
        -display spice-app,gl=on \
        -rtc base=localtime,clock=host
    qemu_status=$?

    sudo ip link delete dev "$tap_name" >/dev/null 2>&1 || \
        printf 'borg_vm_alt: warning: could not delete TAP device %s\n' "$tap_name" >&2
    return "$qemu_status"
)
