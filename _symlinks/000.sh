#!/usr/bin/env bash
set -euo pipefail

OSA_BASE="/osa"
USER_NAME="qqq"

# Map: source path -> relative path under /osa
declare -A MAP
MAP["/var/lib/snapd"]="/var/lib/snapd"
MAP["/var/cache/snapd"]="/var/cache/snapd"
MAP["/var/lib/apt"]="/var/lib/apt"
MAP["/home/${USER_NAME}/Downloads"]="/home/${USER_NAME}/Downloads"
MAP["/home/${USER_NAME}/tmp"]="/home/${USER_NAME}/tmp"

for src in "${!MAP[@]}"; do
    rel="${MAP[$src]}"
    dst="${OSA_BASE}${rel}"

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

    # Ensure destination directory exists on HDD
    mkdir -p "$dst"

    # If source is non-empty, move its contents
    if [ -n "$(ls -A "$src" 2>/dev/null)" ]; then
        mv "$src/"* "$dst"/
    fi

    # Bind-mount
    mount --bind "$dst" "$src"
    echo "[BIND] Mounted $dst on $src"
done

echo ""
echo "=== To make permanent, add these lines to /etc/fstab (only for paths that were actually moved): ==="
for src in "${!MAP[@]}"; do
    rel="${MAP[$src]}"
    dst="${OSA_BASE}${rel}"
    if mountpoint -q "$src"; then
        printf "%s  %s  none  bind  0  0\n" "$dst" "$src"
    fi
done
