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

borg_spent() {
    printf 'spent:%s:%s\n' "$1" "$2"
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

USER_RSYNC_CAPTURE="$(mktemp)"
MIGRATION_CAPTURE="$(mktemp)"
trap 'rm -f -- "$CAPTURE_FILE" "$USER_RSYNC_CAPTURE" "$MIGRATION_CAPTURE"' EXIT

rsync() {
    printf '%s\n' "$@" > "$USER_RSYNC_CAPTURE"
    printf 'rsync: simulated user-mode failure\n' >&2
    return 24
}

set +e
USER_OUTPUT="$(bash_fs_rsync_as_user /source-user/ user@host:/target-user/ 2>&1)"
USER_RSYNC_STATUS=$?
set -e

grep -Fxq '/source-user/' "$USER_RSYNC_CAPTURE" \
    || fail "user-mode rsync did not receive the source path"
grep -Fxq 'user@host:/target-user/' "$USER_RSYNC_CAPTURE" \
    || fail "user-mode rsync did not receive the remote target path"
! grep -Fq -- '--rsync-path=' "$USER_RSYNC_CAPTURE" \
    || fail "user-mode rsync invoked remote sudo"
[[ "$USER_OUTPUT" == *'simulated user-mode failure'* ]] \
    || fail "user-mode rsync did not report rsync stderr"
[[ "$USER_OUTPUT" == *'spent:'* ]] \
    || fail "user-mode rsync did not report elapsed time"
[[ "$USER_RSYNC_STATUS" -eq 24 ]] \
    || fail "user-mode rsync did not preserve rsync failure status"

bash_fs_rsync_as_user() {
    printf '%s\t%s\n' "$1" "$2" >> "$MIGRATION_CAPTURE"
}

borg_fs_to_xxx

[[ "$(wc -l < "$MIGRATION_CAPTURE")" -eq 2 ]] \
    || fail "xxx migration did not schedule exactly the workspace and global rules"
grep -Fxq $'/home/qqq/_A001/\tqqq@xxx:/home/qqq/_A001/' "$MIGRATION_CAPTURE" \
    || fail "xxx migration did not schedule the canonical workspace"
grep -Fxq $'/mnt/d64vik/qqq/_ai/agents/AGENTS.md\tqqq@xxx:/home/qqq/AGENTS.md' "$MIGRATION_CAPTURE" \
    || fail "xxx migration did not dereference and schedule the global AI rules"

MIGRATION_CALLS=0
bash_fs_rsync_as_user() {
    ((MIGRATION_CALLS += 1))
    [[ "$MIGRATION_CALLS" -ne 1 ]]
}

set +e
borg_fs_to_xxx
MIGRATION_STATUS=$?
set -e

[[ "$MIGRATION_STATUS" -ne 0 ]] \
    || fail "xxx migration hid a failed workspace transfer"
[[ "$MIGRATION_CALLS" -eq 1 ]] \
    || fail "xxx migration continued after a failed workspace transfer"

echo "PASS: borg rsync error reporting and log lifecycle"
