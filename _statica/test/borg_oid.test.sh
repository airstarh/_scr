#!/bin/bash

set -euo pipefail

BORG_OID_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)/bin/function/borg_oid.sh"
BORG_OID_FILE="${BORG_OID_FILE_OVERRIDE:-$BORG_OID_FILE}"
TEST_DIR="$(mktemp -d)"
ADB_LOG="$TEST_DIR/adb.log"
export ADB_LOG
trap 'rm -rf -- "$TEST_DIR"' EXIT

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

cat > "$TEST_DIR/adb" <<'EOF'
#!/bin/bash
set -euo pipefail

command_line="$*"
printf '%s\n' "$command_line" >> "$ADB_LOG"

if [[ "$command_line" == *"content query --user 12"* ]]; then
    cat <<'ROWS'
Row: 0 _id=100, _data=/storage/emulated/12/DCIM/Camera, format=12289
Row: 1 _id=101, _data=/storage/emulated/12/DCIM/Camera/My photo.jpg, format=14337
Row: 2 _id=102, _data=/storage/emulated/12/DCIM/Screenshots/Shot.png, format=14337
Row: 3 _id=103, _data=/storage/emulated/12/DCIM/Camera/metadata.dat, format=12288
ROWS
elif [[ -n "${ADB_FAIL_URI:-}" && "$command_line" == *"$ADB_FAIL_URI"* ]]; then
    exit 7
elif [[ "$command_line" == *"test -e --"* ]]; then
    echo "test: unexpected operator/operand" >&2
    exit 2
elif [[ "$command_line" == *"test -e "* ]]; then
    if [[ -n "${ADB_EXISTING_PATH:-}" && "$command_line" == *"$ADB_EXISTING_PATH"* ]]; then
        exit 0
    fi
    exit 1
fi
EOF
chmod +x "$TEST_DIR/adb"
PATH="$TEST_DIR:$PATH"
export PATH

# shellcheck disable=SC1090
source "$BORG_OID_FILE"

borg_oid_DCIM_to_sp1 >/dev/null

grep -Fq 'content://media/external/file/101' "$ADB_LOG" \
    || fail "first media file was not copied"
grep -Fq '/storage/emulated/0/_A001.sp1/DCIM/Camera/My\ photo.jpg.partial' "$ADB_LOG" \
    || fail "destination path with spaces was not preserved"
grep -Fq 'content://media/external/file/102' "$ADB_LOG" \
    || fail "nested media file was not copied"
grep -Fq 'content://media/external/file/103' "$ADB_LOG" \
    || fail "ordinary non-media file was not copied"
grep -Fq '/storage/emulated/0/_A001.sp1/DCIM/Camera/metadata.dat.partial' "$ADB_LOG" \
    || fail "ordinary non-media destination path was not preserved"
if grep -Fq 'content://media/external/file/100' "$ADB_LOG"; then
    fail "directory row was treated as a file"
fi

: > "$ADB_LOG"
export ADB_EXISTING_PATH='Camera/My\ photo.jpg'
borg_oid_DCIM_to_sp1 >/dev/null
if grep -Fq 'content://media/external/file/101' "$ADB_LOG"; then
    fail "existing destination file was copied again"
fi
grep -Fq 'content://media/external/file/102' "$ADB_LOG" \
    || fail "non-existing destination file was not copied"
grep -Fq 'content://media/external/file/103' "$ADB_LOG" \
    || fail "a file without a completed destination was not copied"

: > "$ADB_LOG"
unset ADB_EXISTING_PATH
export ADB_FAIL_URI='content://media/external/file/101'
if borg_oid_DCIM_to_sp1 >/dev/null 2>&1; then
    fail "copy failure was not returned to the caller"
fi
if grep -Fq 'content://media/external/file/102' "$ADB_LOG"; then
    fail "copy continued after a failed file"
fi

echo "PASS: borg_oid DCIM copy"
