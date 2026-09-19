#! /bin/bash

# Show even unmounted disks
borg_fs_disks() {
    lsblk -f -o NAME,FSTYPE,SIZE,MOUNTPOINT
}
