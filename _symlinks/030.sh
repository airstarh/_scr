#!/usr/bin/env bash
set -euo pipefail

USER_NAME="qqq"
OSA_BASE="/osa"

# Define what we want to move (source -> relative path under /osa)
declare -A MAP
MAP["/var/lib/snapd"]="/var/lib/snapd"
MAP["/var/cache/snapd"]="/var/cache/snapd"
MAP["/var/lib/apt"]="/var/lib/apt"
MAP["/home/${USER_NAME}/Downloads"]="/home/${USER_NAME}/Downloads"
MAP["/home/${USER_NAME}/tmp"]="/home/${USER_NAME}/tmp"

BACKUP_DIR="/root/bind-move-backup-$(date +%F-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "=== Backup directory: $BACKUP_DIR ==="

# Stop snapd only if we are touching its data
if [[ -n "${MAP["/var/lib/snapd"]+x}" || -n "${MAP["/var/cache/snapd"]+x}" ]]; then
    if systemctl is-active --quiet snapd; then
        echo "Stopping snapd..."
        systemctl stop snapd
    fi
fi

for src in "${!MAP[@]}"; do
    rel="${MAP[$src]}"
    dst="$OSA_BASE/$rel"

    # Skip if already bound
    if mountpoint -q "$src"; then
        echo "[SKIP] $src is already bound."
        continue
    fi

    # Skip if source doesn't exist
    if [ ! -d "$src" ]; then
        echo "[SKIP] $src does not exist."
        continue
    fi

    echo "[PROCESS] $src -> $dst"

    # Create full destination path on HDD
    mkdir -p "$(dirname "$dst")"

    # Backup original contents to timestamped dir (preserve structure)
    mkdir -p "$BACKUP_DIR/$rel"
    # Copy everything inside $src (not $src itself)
    if [ -n "$(ls -A "$src" 2>/dev/null)" ]; then
        cp -a "$src/"* "$BACKUP_DIR/$rel/"
    fi

    # Move contents from src to dst
    if [ -n "$(ls -A "$src" 2>/dev/null)" ]; then
        mv "$src/"* "$dst"/
    fi

    # Bind mount
    mount --bind "$dst" "$src"
    echo "[BIND] Mounted $dst on $src"
done

# Start snapd if we stopped it and it’s enabled
if [[ -n "${MAP["/var/lib/snapd"]+x}" || -n "${MAP["/var/cache/snapd"]+x}" ]]; then
    if systemctl is-enabled --quiet snapd 2>/dev/null && ! systemctl is-active --quiet snapd; then
        echo "Starting snapd..."
        systemctl start snapd
    fi
fi

echo ""
echo "=== Final status ==="
for src in "${!MAP[@]}"; do
    if mountpoint -q "$src"; then
        echo "[OK] $src is bound."
    else
        echo "[FAIL] $src is NOT bound!"
        exit 1
    fi
done

echo ""
echo "To make these permanent, manually add the following lines to /etc/fstab (only for sources that were actually moved):"
for src in "${!MAP[@]}"; do
    rel="${MAP[$src]}"
    dst="$OSA_BASE/$rel"
    if mountpoint -q "$src"; then
        # Normalize double slashes just in case
        dst_norm=$(echo "$dst" | sed 's|//*|/|g')
        src_norm=$(echo "$src" | sed 's|//*|/|g')
        printf "%s  %s  none  bind  0  0\n" "$dst_norm" "$src_norm"
    fi
done
