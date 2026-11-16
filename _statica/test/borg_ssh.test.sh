#!/bin/bash

set -euo pipefail

BORG_SSH_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)/bin/function/borg_ssh.sh"
CAPTURE_FILE="$(mktemp)"
trap 'rm -f -- "$CAPTURE_FILE"' EXIT

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

ssh() {
    printf '%s\n' "$@" > "$CAPTURE_FILE"
}

# shellcheck disable=SC1090
source "$BORG_SSH_FILE"
cd /home/qqq/_A001
aaa_codex

grep -Fxq -- '-t' "$CAPTURE_FILE" \
    || fail "aaa_codex did not request an interactive SSH terminal"
grep -Fq 'qqq@192.168.1.47' "$CAPTURE_FILE" \
    || fail "aaa_codex did not connect to aaa"
grep -Fq '/mnt/sshfs/xxx/home-qqq/_A001' "$CAPTURE_FILE" \
    || fail "aaa_codex did not translate the xxx home path"
grep -Fq 'tmux' "$CAPTURE_FILE" \
    || fail "aaa_codex did not use a persistent terminal"
grep -Fq -- '--dangerously-bypass-approvals-and-sandbox' "$CAPTURE_FILE" \
    || fail "aaa_codex did not preserve the requested Codex permission mode"
grep -Fq -- '--no-daemon' "$CAPTURE_FILE" \
    || fail "aaa_codex did not preserve the requested Codex daemon mode"

echo "PASS: aaa_codex path translation and remote launcher"
