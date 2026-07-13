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
        -m 4096 \
        -cpu qemu64 \
        -drive file=/home/qqq/qemu/w7x64_HDA.img,format=raw,if=ide \
        -cdrom /dev/null \
        -boot c \
        -netdev user,id=net0,smb=/home/qqq/shared_qemu/ \
        -device e1000,netdev=net0 \
        -vga qxl \
        -device AC97 \
        -usb \
        -device usb-tablet \
        -monitor stdio \
        -chardev qemu-vdagent,id=vdagent,name=vdagent,clipboard=on \
        -device virtio-serial-pci \
        -device virtserialport,chardev=vdagent,name=com.redhat.spice.0 \
        -display gtk
}
