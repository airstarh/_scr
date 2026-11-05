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
    printf 'rsync: read errors mapping "uncopied-file": Input/output error (5)\n' >&2
    return 23
}

# shellcheck disable=SC1090
source "$BORG_FS_FILE"
set +e
OUTPUT="$(bash_fs_rsync /source /target 2>&1)"
RSYNC_STATUS=$?
set -e
ERROR_REPORT="${OUTPUT##*Files that failed/were skipped (from log)}"

LOG_FILE="$(<"$CAPTURE_FILE")"
[[ "$(basename "$LOG_FILE")" == borg_rsync_errors.*.log ]] \
    || fail "borg rsync did not use its own unique log"
[[ ! -e "$LOG_FILE" ]] \
    || fail "borg rsync did not remove its user-owned log"
[[ "$ERROR_REPORT" == *'uncopied-file'* ]] \
    || fail "borg rsync did not report an uncopied file from rsync stderr"
[[ "$RSYNC_STATUS" -eq 23 ]] \
    || fail "borg rsync did not preserve rsync failure status"

echo "PASS: borg rsync error reporting and log lifecycle"
