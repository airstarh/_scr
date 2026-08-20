#!/bin/bash

borg_fs_A001(){
    rsync -rtlvz --delete --no-perms --no-owner --no-group --progress \
        -i \
        --modify-window=10 \
        /home/qqq/_A001/ \
        qqq@192.168.1.120:/home/qqq/_A001/
}

borg_fs_v(){
    local STARTED=$EPOCHREALTIME

    # REMOVED --ignore-times so rsync can skip unchanged files
    rsync -rtlvz --delete --no-perms --no-owner --no-group --progress \
        -i \
        --modify-window=10 \
        /mnt/d1001/_v/ \
        qqq@192.168.1.120:/mnt/d1001/_v/

    local ENDED=$EPOCHREALTIME
    borg_spent $STARTED $ENDED
}



