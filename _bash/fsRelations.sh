#!/bin/bash
# DYNAMIC STORAGE MAP - Auto-discovers all symlinks and bind mounts
# Scans up to 4 levels deep with no hardcoded paths

echo "========================================="
echo "     SYSTEM STORAGE MAP (Dynamic)"
echo "========================================="
echo ""

# Get devices
ROOT_DEV=$(df / | awk 'NR==2 {print $1}')
echo "📀 System device: $ROOT_DEV"

# Find data mount (if exists)
DATA_MOUNT=""
if mountpoint -q /osa 2>/dev/null; then
    DATA_MOUNT="/osa"
    DATA_DEV=$(df /osa | awk 'NR==2 {print $1}')
    echo "📀 Data device: $DATA_DEV at $DATA_MOUNT"
fi
echo ""

# Arrays to store discovered redirections (avoid duplicates)
declare -A SEEN_SYMLINKS
declare -A SEEN_BIND_MOUNTS

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔗 REDIRECTIONS (Auto-discovered, up to 4 levels deep)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Function to scan directories recursively (max depth 4)
scan_for_redirections() {
    local dir="$1"
    local depth="$2"
    local max_depth=4

    # Skip pseudo-filesystems and /osa itself
    if [[ "$dir" == "/proc" ]] || [[ "$dir" == "/sys" ]] || [[ "$dir" == "/dev" ]] || [[ "$dir" == "/run" ]] || [[ "$dir" == "/osa" ]]; then
        return
    fi

    # Skip if depth exceeded
    if [[ $depth -gt $max_depth ]]; then
        return
    fi

    # Scan all items in directory
    for item in "$dir"/*; do
        # Skip if doesn't exist
        [[ ! -e "$item" ]] && continue

        # Check for SYMLINKS
        if [[ -L "$item" ]]; then
            target=$(readlink -f "$item" 2>/dev/null)
            if [[ -n "$target" ]] && [[ -e "$target" ]]; then
                # Get devices
                link_dev=$(df "$(dirname "$item")" 2>/dev/null | awk 'NR==2 {print $1}')
                target_dev=$(df "$target" 2>/dev/null | awk 'NR==2 {print $1}')

                # Only show if it crosses devices or points to data mount
                if [[ "$link_dev" != "$target_dev" ]] || [[ "$target" == "$DATA_MOUNT"* ]]; then
                    # Create unique key
                    key="$item"
                    if [[ -z "${SEEN_SYMLINKS[$key]}" ]]; then
                        SEEN_SYMLINKS[$key]=1
                        link_dev_clean=$(echo "$link_dev" | sed 's|/dev/||')
                        target_dev_clean=$(echo "$target_dev" | sed 's|/dev/||')
                        printf "  [SL] %-8s ::: %-35s → %-8s ::: %s\n" "$link_dev_clean" "$item" "$target_dev_clean" "$target"
                    fi
                fi
            fi
        fi

        # Recurse into subdirectories (but limit depth)
        if [[ -d "$item" ]] && [[ ! -L "$item" ]] && [[ $depth -lt $max_depth ]]; then
            # Only scan important directories at deeper levels
            local basename=$(basename "$item")
            if [[ $depth -eq 1 ]] || [[ "$basename" =~ ^(lib|etc|var|opt|usr|home|srv|root|mnt|media)$ ]]; then
                scan_for_redirections "$item" $((depth + 1))
            fi
        fi
    done
}

# Function to discover bind mounts
discover_bind_mounts() {
    # Find all bind mounts by looking at mount points
    mount | while read line; do
        local target=$(echo "$line" | awk '{print $3}')

        # Only consider real directories (not pseudo)
        if [[ -d "$target" ]] && [[ "$target" != "/" ]] && [[ "$target" != "/osa" ]] && [[ "$target" != "/osa"* ]]; then
            local source_dev=$(df "$target" 2>/dev/null | awk 'NR==2 {print $1}')

            # Check if this is a bind mount (source device is DATA_DEV but target not under /osa)
            if [[ -n "$DATA_DEV" ]] && [[ "$source_dev" == "$DATA_DEV" ]] && [[ "$target" != "$DATA_MOUNT"* ]]; then
                # Create unique key
                if [[ -z "${SEEN_BIND_MOUNTS[$target]}" ]]; then
                    SEEN_BIND_MOUNTS[$target]=1
                    source_dev_clean=$(echo "$source_dev" | sed 's|/dev/||')
                    target_dev_clean=$(echo "$DATA_DEV" | sed 's|/dev/||')
                    # Find corresponding path on data mount
                    data_path="$DATA_MOUNT$target"
                    printf "  [BM] %-8s ::: %-35s → %-8s ::: %s\n" "$source_dev_clean" "$target" "$target_dev_clean" "$data_path"
                fi
            fi
        fi
    done
}

# Start scanning from root (depth 1)
scan_for_redirections "/" 1

# Discover bind mounts
discover_bind_mounts

# If no redirections found, show message
if [[ ${#SEEN_SYMLINKS[@]} -eq 0 ]] && [[ ${#SEEN_BIND_MOUNTS[@]} -eq 0 ]]; then
    echo "  No redirections found (symlinks or bind mounts)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SSD ($ROOT_DEV): $(df -h / | awk 'NR==2 {print $3" / "$2}')"
if [[ -n "$DATA_MOUNT" ]]; then
    echo "  HDD ($DATA_DEV): $(df -h $DATA_MOUNT | awk 'NR==2 {print $3" / "$2}')"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 SCAN NOTES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  • Scanned symlinks up to 4 levels deep"
echo "  • Skipped /proc, /sys, /dev, /run, /osa"
echo "  • Showing only cross-device symlinks and bind mounts"
