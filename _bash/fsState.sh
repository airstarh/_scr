#!/bin/bash
# System Layout Visualizer - Shows where your data lives

echo "========================================="
echo "     SYSTEM STORAGE LAYOUT"
echo "========================================="

# Get SSD info (where / is mounted)
SSD_DEV=$(df / | awk 'NR==2 {print $1}')
SSD_SIZE=$(lsblk -o SIZE -n -d $SSD_DEV 2>/dev/null | head -1)
SSD_USED=$(df -h / | awk 'NR==2 {print $3}')
SSD_PERCENT=$(df -h / | awk 'NR==2 {print $5}')

# Get HDD info (/osa mount)
HDD_DEV=$(df /osa | awk 'NR==2 {print $1}')
HDD_SIZE=$(lsblk -o SIZE -n -d $HDD_DEV 2>/dev/null | head -1)
HDD_USED=$(df -h /osa | awk 'NR==2 {print $3}')
HDD_FREE=$(df -h /osa | awk 'NR==2 {print $4}')

echo ""
echo "📊 DISK SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "💾 SSD (%s - %s): %s used (%s)\n" "$SSD_DEV" "$SSD_SIZE" "$SSD_USED" "$SSD_PERCENT"
printf "💾 HDD (%s - %s): %s used, %s free\n" "$HDD_DEV" "$HDD_SIZE" "$HDD_USED" "$HDD_FREE"

echo ""
echo "📁 DIRECTORY LAYOUT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Function to check if path is on HDD
is_on_hdd() {
    if [ -L "$1" ] || [ -d "$1" ]; then
        TARGET=$(readlink -f "$1" 2>/dev/null)
        if [[ "$TARGET" == /osa/* ]]; then
            return 0  # On HDD
        fi
    fi
    return 1  # Not on HDD
}

# Function to get size with nice formatting
get_size() {
    if [ -e "$1" ]; then
        du -sh "$1" 2>/dev/null | awk '{print $1}'
    else
        echo "N/A"
    fi
}

# SSD section
echo "💾 SSD ($SSD_DEV): OS and applications"
echo "   ├── / (root) — System files ($(get_size /))"

# Check each critical location
check_location() {
    local path="$1"
    local description="$2"
    local indent="$3"

    if [ -L "$path" ]; then
        TARGET=$(readlink -f "$path" 2>/dev/null)
        if [[ "$TARGET" == /osa/* ]]; then
            SIZE=$(get_size "$path")
            echo "${indent}├── $path → $TARGET"
            echo "${indent}│   └── 📍 ON HDD ($SIZE)"
        else
            echo "${indent}├── $path (symlink to $TARGET)"
        fi
    elif mountpoint -q "$path" 2>/dev/null; then
        MOUNT=$(mount | grep "on $path " | awk '{print $1}')
        SIZE=$(get_size "$path")
        echo "${indent}├── $path (bind mount from $MOUNT)"
        echo "${indent}│   └── 📍 ON HDD ($SIZE)"
    elif [[ -d "$path" ]]; then
        if [[ "$path" == /osa* ]]; then
            return  # Skip /osa items in SSD section
        fi
        echo "${indent}├── $path — $description ($(get_size "$path"))"
    fi
}

echo ""
echo "💾 HDD ($HDD_DEV at /osa): User data and large files"
echo "   ├── /osa/"

# Check HDD contents
print_hdd_item() {
    local path="/osa/$1"
    local description="$2"
    local prefix="$3"

    if [ -e "$path" ]; then
        SIZE=$(du -sh "$path" 2>/dev/null | awk '{print $1}')
        echo "   │   $prefix├── $1/ — $description ($SIZE)"
    fi
}

print_hdd_item "home" "Your documents, configs, Wine, VMs" "├── "
print_hdd_item "srv" "Web development projects" "├── "
print_hdd_item "var/lib/mysql" "ZoneMinder database" "├── "
print_hdd_item "var/lib/docker" "Docker images and containers" "├── "
print_hdd_item "var/lib/zoneminder" "ZoneMinder configuration" "├── "
print_hdd_item "var/cache/zoneminder" "Camera recordings and events" "└── "

echo "   │"
echo "   └── (and more directories as needed)"

echo ""
echo "🔗 ACTIVE MOUNTS & SYMLINKS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Show bind mounts
mount | grep "/osa" | grep -E "bind|/var/lib" | while read line; do
    echo "✅ Bind mount: $line"
done

# Show symlinks
for link in /home /srv /var/lib/docker; do
    if [ -L "$link" ]; then
        echo "✅ Symlink: $link → $(readlink -f "$link")"
    fi
done

echo ""
echo "🖥️  SERVICE STATUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for service in mysql zoneminder docker; do
    if systemctl is-active --quiet $service; then
        echo "✅ $service is running"
    else
        echo "❌ $service is NOT running"
    fi
done

echo ""
echo "📦 ZONEMINDER DATABASE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
CAMERA_COUNT=$(sudo mysql -e "USE zm; SELECT COUNT(*) FROM Monitors;" 2>/dev/null | tail -1)
if [ -n "$CAMERA_COUNT" ]; then
    echo "✅ Cameras configured: $CAMERA_COUNT"
    echo ""
    echo "Camera details:"
    sudo mysql -e "USE zm; SELECT Id, Name, Type, Enabled FROM Monitors;" 2>/dev/null | while read line; do
        echo "   📹 $line"
    done
else
    echo "⚠️  Cannot connect to ZoneMinder database"
fi

echo ""
echo "========================================="
echo "✅ SYSTEM LAYOUT ANALYSIS COMPLETE"
echo "========================================="
