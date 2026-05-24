#!/bin/bash
qemu-system-x86_64 \
    -enable-kvm \
    -m 4096 \
    -cpu qemu64 \
    -drive file=/home/qqq/qemu/w7x64_HDA.img,format=raw,if=ide \
    -cdrom /dev/null \
    -boot c \
    -net user,smb=/home/qqq/shared_qemu/ \
    -net nic,model=virtio \
    -vga qxl \
    -device AC97 \
    -usb \
    -device usb-tablet \
    -monitor stdio
