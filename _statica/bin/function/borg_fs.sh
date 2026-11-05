#!/bin/bash

borg_dir() {
    echo "$(cd "$(dirname "${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}")" && pwd)"
}


bash_fs_rsync() {
    local source_dir="$1"
    local target_dir="$2"
    local log_file
    local rsync_status

    log_file="$(mktemp /tmp/borg_rsync_errors.XXXXXX.log)" || return

    borg_sudo rsync -rtlvz \
        --delete-after \
        --no-perms \
        --no-owner \
        --no-group \
        --progress \
        -i \
        --modify-window=10 \
        --rsync-path="sudo rsync" \
        -e ssh \
        "$source_dir" \
        "$target_dir" 2>&1 | tee "$log_file"
    rsync_status=${PIPESTATUS[0]}

    echo ""
    echo "============================================================"
    echo "============================================================"
    echo "============================================================"
    echo "Files that failed/were skipped (from log)"
    grep -E '^(rsync:|rsync error:|skipping )' "$log_file" || echo "No errors found"
    rm -f -- "$log_file"

    return "$rsync_status"
}



borg_fs_sync(){
    local STARTED=$EPOCHREALTIME
    ##################################################
    borg_fs_A001
    # borg_fs_v
    ##################################################
    local ENDED=$EPOCHREALTIME
    borg_spent $STARTED $ENDED
}

borg_fs_A001(){
    bash_fs_rsync "/home/qqq/_A001/" "qqq@bbb:/mnt/d1000/_A001.all/_A001.aaa/"
}

borg_fs_v(){
    bash_fs_rsync "/mnt/d501aaa/_v/" "qqq@bbb:/mnt/d1001/_v/"
}

# DANGEROUS
# borg_fs_bdbmysql(){
#     bash_fs_rsync "/osa/_docker/bdb/" "qqq@bbb:/mnt/d1001/_docker/bdb/"
# }

borg_fs_bng(){
    bash_fs_rsync "/osa/_docker/bng/" "qqq@bbb:/mnt/d1001/_docker/bng/"
}

bash_fs_rsync_local() {
    local source_dir="$1"
    local target_dir="$2"
    local log_file
    local rsync_status

    log_file="$(mktemp /tmp/borg_rsync_errors.XXXXXX.log)" || return

    borg_sudo rsync -rtlv \
        --delete-after \
        --no-perms \
        --no-owner \
        --no-group \
        --progress \
        -i \
        --modify-window=10 \
        "$source_dir" \
        "$target_dir" 2>&1 | tee "$log_file"
    rsync_status=${PIPESTATUS[0]}

    echo ""
    echo "============================================================"
    echo "============================================================"
    echo "============================================================"
    echo "Files that failed/were skipped (from log)"
    grep -E '^(rsync:|rsync error:|skipping )' "$log_file" || echo "No errors found"
    rm -f -- "$log_file"

    return "$rsync_status"
}

borg_fs_draft(){
    bash_fs_rsync_local "/run/media/qqq/RM-X-500/" "/home/qqq/_A001/_from_rm-x-500/"
}
