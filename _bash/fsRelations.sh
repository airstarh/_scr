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

# Find data mount dynamically (largest non-root mount)
DATA_MOUNT=""
DATA_DEV=""

# Try to detect data mount (look for mount that's not / and not pseudo)
while read -r mount_point; do
    if [[ "$mount_point" != "/" ]] && [[ "$mount_point" != "/boot" ]] && [[ "$mount_point" != "/boot/efi" ]] && [[ "$mount_point" != "/snap"* ]] && [[ -d "$mount_point" ]]; then
        # Check if it's a real disk (not tmpfs, devtmpfs, etc)
        mount_dev=$(df "$mount_point" 2>/dev/null | awk 'NR==2 {print $1}')
        if [[ "$mount_dev" == /dev/* ]] && [[ "$mount_dev" != "$ROOT_DEV" ]]; then
            DATA_MOUNT="$mount_point"
            DATA_DEV="$mount_dev"
            break
        fi
    fi
done < <(mount | grep -E "^/dev/" | awk '{print $3}')

if [[ -n "$DATA_MOUNT" ]]; then
    echo "📀 Data device: $DATA_DEV at $DATA_MOUNT"
else
    echo "📀 No secondary data mount detected"
fi
echo ""

# Arrays to store discovered redirections (avoid duplicates)
declare -A SEEN_SYMLINKS
declare -A SEEN_BIND_MOUNTS

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔗 REDIRECTIONS (Auto-discovered, up to 4 levels deep)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Clean path function (removes double slashes)
clean_path() {
    echo "$1" | sed 's|//*|/|g'
}

# Function to scan directories recursively (max depth 4)
scan_for_redirections() {
    local dir="$1"
    local depth="$2"
    local max_depth=4

    # Clean the directory path
    dir=$(clean_path "$dir")

    # Skip pseudo-filesystems and data mount itself
    if [[ "$dir" == "/proc" ]] || [[ "$dir" == "/sys" ]] || [[ "$dir" == "/dev" ]] || [[ "$dir" == "/run" ]]; then
        return
    fi

    # Skip if we're inside the data mount (to avoid circular scanning)
    if [[ -n "$DATA_MOUNT" ]] && [[ "$dir" == "$DATA_MOUNT"* ]] && [[ "$dir" != "$DATA_MOUNT" ]]; then
        return
    fi

    # Skip if depth exceeded
    if [[ $depth -gt $max_depth ]]; then
        return
    fi

    # Ensure directory exists and is readable
    if [[ ! -d "$dir" ]]; then
        return
    fi

    # Scan all items in directory
    for item in "$dir"/*; do
        # Skip if doesn't exist
        [[ ! -e "$item" ]] && continue

        # Clean the item path
        item=$(clean_path "$item")

        # Check for SYMLINKS
        if [[ -L "$item" ]]; then
            target=$(readlink -f "$item" 2>/dev/null)
            if [[ -n "$target" ]]; then
                target=$(clean_path "$target")
                # Get devices (use dirname for symlink location)
                link_dev=$(df "$(dirname "$item")" 2>/dev/null | awk 'NR==2 {print $1}')
                target_dev=$(df "$target" 2>/dev/null | awk 'NR==2 {print $1}')

                # Use "unknown" for pseudo devices
                [[ -z "$link_dev" ]] && link_dev="unknown"
                [[ -z "$target_dev" ]] && target_dev="unknown"

                # Only show if it's interesting (cross-device, points to data mount, or system symlink)
                if [[ "$link_dev" != "$target_dev" ]] || [[ "$target" == "$DATA_MOUNT"* ]] || [[ "$item" == "/bin" ]] || [[ "$item" == "/lib" ]] || [[ "$item" == "/lib64" ]] || [[ "$item" == "/sbin" ]]; then
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
            if [[ $depth -eq 1 ]] || [[ "$basename" =~ ^(bin|lib|etc|var|opt|usr|home|srv|root|mnt|media)$ ]]; then
                scan_for_redirections "$item" $((depth + 1))
            fi
        fi
    done
}

# Discover bind mounts from /proc/self/mountinfo
discover_bind_mounts() {
    # First, build an associative array mapping device IDs to their original mount points
    declare -A device_to_mount

    while IFS= read -r line; do
        dev_id=$(echo "$line" | awk '{print $3}')
        mount_point=$(echo "$line" | awk '{print $5}')
        mount_source=$(echo "$line" | sed 's/^[^-]* - //' | awk '{print $2}')

        # Only track real device mounts (not tmpfs, etc)
        if [[ "$mount_source" == /dev/* ]]; then
            device_to_mount["$dev_id"]="$mount_point"
        fi
    done < /proc/self/mountinfo

    # Now find bind mounts
    while IFS= read -r line; do
        # Parse mountinfo line
        mount_id=$(echo "$line" | awk '{print $1}')
        parent_id=$(echo "$line" | awk '{print $2}')
        dev_id=$(echo "$line" | awk '{print $3}')
        root=$(echo "$line" | awk '{print $4}')
        mount_point=$(echo "$line" | awk '{print $5}')
        mount_options=$(echo "$line" | awk '{print $6}')

        # Extract fields after separator
        rest=$(echo "$line" | sed 's/^[^-]* - //')
        fs_type=$(echo "$rest" | awk '{print $1}')
        mount_source=$(echo "$rest" | awk '{print $2}')

        # Skip pseudo filesystems
        [[ "$mount_point" == "/proc"* ]] && continue
        [[ "$mount_point" == "/sys"* ]] && continue
        [[ "$mount_point" == "/dev"* ]] && continue
        [[ "$mount_point" == "/run"* ]] && continue
        [[ "$mount_point" == "/" ]] && continue

        # Check if this is a bind mount (mount_source is a path, not a device)
        if [[ "$mount_source" == /* ]] && [[ "$mount_source" != /dev/* ]]; then
            # Get the original device mount point for this device ID
            original_mount="${device_to_mount[$dev_id]}"

            if [[ -n "$original_mount" ]]; then
                # Determine the correct source path
                if [[ "$root" == "/" ]]; then
                    source_path="$original_mount"
                else
                    source_path="$original_mount$root"
                fi
                source_path=$(clean_path "$source_path")

                # Get device for display (from the target mount point)
                mount_dev=$(df "$mount_point" 2>/dev/null | awk 'NR==2 {print $1}')
                [[ -z "$mount_dev" ]] && mount_dev="unknown"
                mount_dev_clean=$(echo "$mount_dev" | sed 's|/dev/||')

                # Get source device (from the original mount point)
                source_dev=$(df "$source_path" 2>/dev/null | awk 'NR==2 {print $1}')
                [[ -z "$source_dev" ]] && source_dev="$mount_dev"
                source_dev_clean=$(echo "$source_dev" | sed 's|/dev/||')

                # Create unique key
                key="$mount_point"
                if [[ -z "${SEEN_BIND_MOUNTS[$key]}" ]]; then
                    SEEN_BIND_MOUNTS[$key]=1
                    printf "  [BM] %-8s ::: %-35s → %-8s ::: %s\n" "$source_dev_clean" "$mount_point" "$mount_dev_clean" "$source_path"
                fi
            fi
        fi
    done < /proc/self/mountinfo
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
echo "  • Bind mounts detected from /proc/self/mountinfo"
echo "  • Data mount auto-detected (no hardcoded paths)"
echo "  • Showing cross-device symlinks and bind mounts"s
