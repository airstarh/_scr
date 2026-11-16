# Migration plan and check-list

~ = /home/qqq

### Directories

```
REQUIRED:   /home/qqq/_A001
REQUIRED:   /home/qqq/.ssh
OPTIONAL:   /home/qqq/_A002
```

### .bashrc

Important rows:

```
####################################################################################################
source ~/_A001/_scr/_statica/index.sh
####################################################################################################
```

### Software REQUIRED

- vscode
- dbeaver-ce
- git
- google.chrome.stabel
- qemu
- docker
- KDE plugin: freeze screen by Ctrl+1
- Solar - for Logitech Mouse
- Input Remapper - for mouse and other devices

## Special Mount Bounds

fstab adjustment required.

```
/srv/_v
    aaa: [disk:d501aaa]/_v
    xxx: [disk:nvme]/_v
```

It all is necessary for qemu virtual machines which are running from:
    - /home/qqq/_A001/_scr/_statica/bin/function/borg_vm_alt.sh
    - /home/qqq/_A001/_scr/_statica/bin/function/borg_vm.sh
