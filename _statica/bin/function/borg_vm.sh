#! /bin/bash

borg_vm() {
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
    -monitor stdio
}