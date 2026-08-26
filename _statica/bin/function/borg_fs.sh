#!/bin/bash

bash_fs_rsync() {
    local source_dir="$1"
    local target_dir="$2"

    rsync -rtlvz \
        --delete-after \
        --no-perms \
        --no-owner \
        --no-group \
        --progress \
        -i \
        --modify-window=10 \
        --rsync-path="sudo rsync" \
        -e ssh \
        --log-file=/tmp/rsync_errors.log \
        "$source_dir" \
        "$target_dir"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "=== Files that failed/were skipped (from log) ==="
    grep -E "failed|skipped|error" /tmp/rsync_errors.log || echo "No errors found"
    rm -f /tmp/rsync_errors.log
}



borg_fs_sync(){
    local STARTED=$EPOCHREALTIME
    ##################################################
    borg_fs_A001
    # borg_fs_v
    # borg_fs_docker
    ##################################################
    local ENDED=$EPOCHREALTIME
    borg_spent $STARTED $ENDED
}
borg_fs_A001(){
    bash_fs_rsync "/home/qqq/_A001/" "qqq@bbb:/home/qqq/_A001/"
}

borg_fs_v(){
    bash_fs_rsync "/mnt/d1001/_v/" "qqq@bbb:/mnt/d1001/_v/"
}

borg_fs_bdbmysql(){
    bash_fs_rsync "/mnt/d1001/_docker/bdb/" "qqq@bbb:/mnt/d1001/_docker/bdb/"
}

borg_fs_bng(){
    bash_fs_rsync "/mnt/d1001/_docker/bng/" "qqq@bbb:/mnt/d1001/_docker/bng/"
}
