#!/usr/bin/env bash
set -euo pipefail

USER_NAME="qqq"
OSA_BASE="/osa"

check_mount() {
    local target="$1"
    if mountpoint -q "$target"; then
        echo "[OK] $target is already bound to another mount point"
        return 0
    else
        echo "[MISSING] $target is NOT bound yet"
        return 1
    fi
}

echo "=== Checking current bind mounts ==="

# Snap
check_mount "/var/lib/snapd"
check_mount "/var/cache/snapd"

# APT
check_mount "/var/lib/apt"

# User dirs (redundant if /home is already fully bound, but we check anyway)
check_mount "/home/${USER_NAME}/Downloads"
check_mount "/home/${USER_NAME}/tmp"

echo ""
echo "=== Summary of your existing /osa binds (from mount) ==="
mount | grep "^${OSA_BASE}/" | while read -r line; do
    echo "$line"
done

echo ""
echo "=== Quick size check for key dirs on root FS (if not bound) ==="
for dir in /var/lib/snapd /var/cache/snapd /var/lib/apt; do
    if ! mountpoint -q "$dir"; then
        if [ -d "$dir" ]; then
            du -sh "$dir" 2>/dev/null || echo "$dir: size check failed"
        else
            echo "$dir: directory does not exist"
        fi
    else
        echo "$dir: already bound (size skipped)"
    fi
done
