#!/bin/bash

set -euo pipefail

BORG_FS_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)/bin/function/borg_fs.sh"
BORG_FS_FILE="${BORG_FS_FILE_OVERRIDE:-$BORG_FS_FILE}"
CAPTURE_FILE="$(mktemp)"
trap 'rm -f -- "$CAPTURE_FILE"' EXIT

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

borg_sudo() {
    local log_file=""
    local argument

    for argument in "$@"; do
        case "$argument" in
            --log-file=*) log_file="${argument#--log-file=}" ;;
        esac
    done

    printf '%s\n' "$log_file" > "$CAPTURE_FILE"
    printf 'rsync: failed test entry\n' >> "$log_file"
}

# shellcheck disable=SC1090
source "$BORG_FS_FILE"
bash_fs_rsync /source /target >/dev/null

LOG_FILE="$(<"$CAPTURE_FILE")"
[[ "$(basename "$LOG_FILE")" == borg_rsync_errors.*.log ]] \
    || fail "borg rsync did not use its own unique log"
[[ ! -e "$LOG_FILE" ]] \
    || fail "borg rsync did not remove its user-owned log"

echo "PASS: borg rsync log lifecycle"
