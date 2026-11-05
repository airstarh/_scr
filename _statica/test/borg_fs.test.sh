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
    local argument

    for argument in "$@"; do
        case "$argument" in
            --log-file=*) printf '%s\n' "$argument" > "$CAPTURE_FILE" ;;
        esac
    done

    printf '<f+++++++++ node_modules/error-ex/index.js\n'
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

[[ ! -s "$CAPTURE_FILE" ]] \
    || fail "borg rsync passed its user-owned temporary log to privileged rsync"
[[ "$ERROR_REPORT" == *'uncopied-file'* ]] \
    || fail "borg rsync did not report an uncopied file from rsync stderr"
[[ "$ERROR_REPORT" != *'error-ex/index.js'* ]] \
    || fail "borg rsync reported a successful filename containing error as a failure"
[[ "$RSYNC_STATUS" -eq 23 ]] \
    || fail "borg rsync did not preserve rsync failure status"

echo "PASS: borg rsync error reporting and log lifecycle"
