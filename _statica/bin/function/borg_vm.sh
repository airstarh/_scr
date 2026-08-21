#!/bin/bash

borg_vm() {
    local height=750

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
    -drive file=/mnt/d1001/_v/qemu/w7x64_HDA.img,format=raw,if=ide,cache=writeback \
    -cdrom /dev/null \
    -boot c \
    -netdev user,id=net0,smb=/mnt/d1001/_v/qemu/shara/ \
    -device e1000,netdev=net0 \
    -vga qxl \
    -audiodev pa,id=audio0,server=/run/user/1000/pulse/native \
    -device AC97,audiodev=audio0 \
    -device intel-hda -device hda-duplex,audiodev=audio0 \
    -display spice-app \
    -usb \
    -device usb-tablet \
    -rtc base=localtime,clock=host
}
