#!/usr/bin/env bash
set -euo pipefail

USER_NAME="qqq"
OSA_BASE="/osa"

# Map of source dirs to preserve structure under /osa
declare -A SRC_TO_OSA
SRC_TO_OSA["/var/lib/snapd"]="/var/lib/snapd"
SRC_TO_OSA["/var/cache/snapd"]="/var/cache/snapd"
SRC_TO_OSA["/var/lib/apt"]="/var/lib/apt"
SRC_TO_OSA["/home/${USER_NAME}/Downloads"]="/home/${USER_NAME}/Downloads"
SRC_TO_OSA["/home/${USER_NAME}/tmp"]="/home/${USER_NAME}/tmp"

backup_dir="/root/bind-move-backup-$(date +%F-%H%M%S)"
mkdir -p "$backup_dir"

echo "=== Creating backup dir: $backup_dir ==="

# Stop snapd before touching its data
if systemctl is-active --quiet snapd; then
    echo "Stopping snapd..."
    systemctl stop snapd
fi

for src in "${!SRC_TO_OSA[@]}"; do
    dst_rel="${SRC_TO_OSA[$src]}"
    dst="$OSA_BASE/$dst_rel"

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

    echo "[MOVE] Moving $src -> $dst"

    # Backup original content to timestamped dir
    mkdir -p "$backup_dir/$dst_rel"
    cp -a "$src/"* "$backup_dir/$dst_rel/" 2>/dev/null || true

    # Prepare destination on HDD
    mkdir -p "$(dirname "$dst")"

    # Move content
    mv "$src"/* "$dst"/
    # If src becomes empty dir, leave it; bind will hide it anyway

    # Bind mount
    mount --bind "$dst" "$src"
    echo "[BIND] Mounted $dst on $src"
done

# Start snapd if it was running
if systemctl is-enabled --quiet snapd 2>/dev/null; then
    echo "Starting snapd..."
    systemctl start snapd
fi

echo ""
echo "=== Final mount check ==="
for src in "${!SRC_TO_OSA[@]}"; do
    if mountpoint -q "$src"; then
        echo "[OK] $src is now bound."
    else
        echo "[FAIL] $src is NOT bound!"
        exit 1
    fi
done

echo ""
echo "To make these permanent, add the following lines to /etc/fstab (one per source that was moved):"
for src in "${!SRC_TO_OSA[@]}"; do
    dst="$OSA_BASE/${SRC_TO_OSA[$src]}"
    if mountpoint -q "$src"; then
        echo "$dst  $src  none  bind  0  0"
    fi
done
