#!/bin/bash

bash_fs_rsync() {
    local source_dir="$1"
    local target_dir="$2"

    rsync -rtlvz --delete --no-perms --no-owner --no-group --progress \
        -i \
        --modify-window=10 \
        "$source_dir" \
        "$target_dir"
}


borg_fs_sync(){
    local STARTED=$EPOCHREALTIME
    ##################################################
    borg_fs_A001
    borg_fs_v
    # borg_fs_docker
    ##################################################
    local ENDED=$EPOCHREALTIME
    borg_spent $STARTED $ENDED
}
borg_fs_A001(){
    bash_fs_rsync "/home/qqq/_A001/" "qqq@192.168.1.120:/home/qqq/_A001/"
}

borg_fs_v(){
    bash_fs_rsync "/mnt/d1001/_v/" "qqq@192.168.1.120:/mnt/d1001/_v/"
}

borg_fs_docker(){
    # bash_fs_rsync "/mnt/d1001/_docker/" "qqq@192.168.1.120:/mnt/d1001/_docker/"
    # bash_fs_rsync "/mnt/d1001/_docker/mey/docker-compose.yml" "qqq@192.168.1.120:/mnt/d1001/_docker/mey/docker-compose.yml"
    echo 1234
}



