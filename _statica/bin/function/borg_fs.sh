#!/bin/bash

borg_fs_A001(){
    rsync -rlvz --delete --no-perms --no-owner --no-group --progress \
        --modify-window=2 \
        /home/qqq/_A001/ \
        qqq@192.168.1.120:/home/qqq/_A001/

    rsync -rlvz --delete --no-perms --no-owner --no-group --progress \
        --modify-window=2 \
        /mnt/d1001/_v/ \
        qqq@192.168.1.120:/mnt/d1001/_v/
}
