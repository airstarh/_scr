#!/bin/bash

borg_vm() {
    local height=750
    local spice_socket="/tmp/borg_vm_spice_$$.sock"

    if command -v xrandr >/dev/null 2>&1; then
        local detected
        detected=$(xrandr | grep -E 'current' | head -n1 | awk '{print $(NF-1)}')
        [[ -n "$detected" ]] && height="$detected"
    fi

    echo "Starting QEMU (window size will be managed by KDE; target height ~${height}px)" >&2

    qemu-system-x86_64 \
    -enable-kvm \
    -cpu host \
    -smp cores=2,threads=2,sockets=1 \
    -m 4096 \
    -drive file=/srv/_v/qemu/w7x64_HDA.img,format=raw,if=ide,cache=writeback \
    -cdrom /dev/null \
    -boot c \
    -netdev user,id=net0,smb=/srv/_v/qemu/shara/,dns=8.8.8.8,hostname=guest-vm \
    -device e1000,netdev=net0 \
    -vga qxl \
    -audiodev pa,id=audio0,server=/run/user/1000/pulse/native \
    -device AC97,audiodev=audio0 \
    -device intel-hda \
    -device hda-duplex,audiodev=audio0 \
    -spice "unix=on,addr=${spice_socket},disable-ticketing=on" \
    -display none \
    -usb \
    -device usb-tablet \
    -rtc base=localtime,clock=host &

    local qemu_pid=$!

    # Wait for the SPICE socket to be created (max 5 seconds)
    local i
    for i in $(seq 1 50); do
        [[ -S "$spice_socket" ]] && break
        sleep 0.1
    done

    if [[ ! -S "$spice_socket" ]]; then
        echo "Error: SPICE socket did not appear at $spice_socket" >&2
        kill "$qemu_pid" 2>/dev/null
        wait "$qemu_pid" 2>/dev/null
        return 1
    fi

    # Manually launch spicy to connect to the Unix socket
    spicy --uri="spice+unix://${spice_socket}"

    # After spicy exits, wait for QEMU to finish
    wait "$qemu_pid"
    local ret=$?

    rm -f "$spice_socket"
    return "$ret"
}
