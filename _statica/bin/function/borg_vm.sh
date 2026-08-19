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
        -drive file=/mnt/d1001/_v/qemu/w7x64_HDA.img,format=raw,if=ide \
        -cdrom /dev/null \
        -boot c \
        -netdev user,id=net0,smb=/mnt/d1001/_v/qemu/shara/ \
        -device e1000,netdev=net0 \
        -vga qxl \
        -audiodev pa,id=audio0,server=/run/user/1000/pulse/native \
        -device AC97,audiodev=audio0 \
        -audiodev pa,id=audio1,server=/run/user/1000/pulse/native \
        -device intel-hda -device hda-duplex,audiodev=audio1 \
        -usb \
        -device usb-tablet \
        -monitor stdio \
        -chardev qemu-vdagent,id=vdagent,name=vdagent,clipboard=on \
        -device virtio-serial-pci \
        -device virtserialport,chardev=vdagent,name=com.redhat.spice.0 \
        -display gtk
}
