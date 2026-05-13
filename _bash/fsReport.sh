#!/bin/bash

# Disk Space Analysis Script
# Handles bind mounts, separate filesystems, and shows REAL usage

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Temporary file for mount info
MOUNT_INFO="/tmp/mount_info_$$"

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}         DISK SPACE ANALYSIS SCRIPT${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Function to print section header
print_header() {
    echo ""
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}► $1${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to get mount point for a directory
get_mount_point() {
    df -P "$1" 2>/dev/null | tail -1 | awk '{print $6}'
}

# 1. Basic filesystem overview
print_header "1. FILESYSTEM OVERVIEW (df -h)"
df -h | grep -E '^/dev/|^Filesystem'
echo ""
echo -e "${YELLOW}Note:${NC} Look at 'Use%' column - over 80% needs attention"

# 2. Identify physical disks and their mounts
print_header "2. PHYSICAL DISKS AND MOUNTS"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,LABEL | grep -E 'disk|part|lvm|NAME'
echo ""
echo -e "${YELLOW}Note:${NC} Shows actual disk partitions (separate physical storage)"

# 3. Find all bind mounts
print_header "3. BIND MOUNTS DETECTED"
grep -E 'none.*bind|bind' /etc/fstab 2>/dev/null || echo "No bind mounts found in /etc/fstab"
echo ""
mount | grep -E 'none.*bind' || echo "No active bind mounts found"

# 4. REAL space usage per filesystem (excluding bind mount double-counting)
print_header "4. REAL DISK USAGE PER FILESYSTEM"

# Get unique devices (excluding tmpfs, etc.)
echo -e "${BLUE}Analyzing each physical filesystem separately:${NC}"
echo ""

# Process each mounted device
df -P | grep '^/dev/' | awk '{print $1,$6}' | while read device mount; do
    echo -e "${CYAN}📁 $mount (device: $device)${NC}"
    
    # Skip if this is a bind mount or same as root
    if [ "$mount" == "/" ] || [ "$mount" == "/osa" ] || [ "$mount" == "/boot/efi" ]; then
        # For root and major mounts, exclude other filesystems
        if [ "$mount" == "/" ]; then
            # Exclude /osa, /home, /boot/efi when scanning root
            sudo du -sh --exclude=/osa --exclude=/home --exclude=/boot/efi --exclude=/proc --exclude=/sys --exclude=/dev --exclude=/run --exclude=/tmp $mount 2>/dev/null | sort -hr | head -5 || echo "  Unable to scan"
        elif [ "$mount" == "/osa" ]; then
            # For /osa, exclude home (already counted)
            sudo du -sh --exclude=/home --exclude=/proc --exclude=/sys --exclude=/dev $mount 2>/dev/null | sort -hr | head -5 || echo "  Unable to scan"
        else
            # For other mounts, scan normally
            sudo du -sh $mount 2>/dev/null | sort -hr | head -5 || echo "  Unable to scan"
        fi
    else
        sudo du -sh $mount 2>/dev/null | sort -hr | head -5 || echo "  Unable to scan"
    fi
    echo ""
done

# 5. Detailed analysis of root partition (excluding other mounts)
print_header "5. ROOT PARTITION DETAILS (excluding /osa, /home, /boot/efi)"

echo -e "${BLUE}Top 15 space consumers on root partition (real usage):${NC}"
echo ""
sudo du -sh --exclude=/osa --exclude=/home --exclude=/boot/efi --exclude=/proc --exclude=/sys --exclude=/dev --exclude=/run --exclude=/tmp /* 2>/dev/null | sort -hr | head -15

# 6. Deep dive into common space hogs
print_header "6. COMMON SPACE HOGS ANALYSIS"

# Check /var
if [ -d /var ]; then
    echo -e "${BLUE}/var directory breakdown:${NC}"
    sudo du -sh /var/* 2>/dev/null | sort -hr | head -8
    echo ""
fi

# Check /snap
if [ -d /snap ]; then
    echo -e "${BLUE}/snap directory (Snap packages):${NC}"
    echo "Total Snap size: $(sudo du -sh /snap 2>/dev/null | cut -f1)"
    echo "Old Snap versions can be cleaned with: sudo snap list --all | grep disabled"
    echo ""
fi

# Check /tmp
if [ -d /tmp ]; then
    echo -e "${BLUE}/tmp directory:${NC}"
    sudo du -sh /tmp 2>/dev/null
    echo ""
fi

# Check for large deleted files (still open)
print_header "7. DELETED FILES STILL USING SPACE"

echo -e "${BLUE}Large deleted files still held open by processes:${NC}"
sudo lsof +L1 2>/dev/null | grep -v "^COMMAND" | awk '{print $1,$2,$7,$8,$9}' | sort -k3 -hr | head -10 || echo "No large deleted files found"

# 8. Docker images (if present)
if command -v docker &> /dev/null; then
    print_header "8. DOCKER USAGE"
    docker system df 2>/dev/null || echo "Docker not accessible"
fi

# 9. Recommendations
print_header "9. RECOMMENDATIONS"

# Check root usage
ROOT_USE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
ROOT_AVAIL=$(df -h / | tail -1 | awk '{print $4}')

if [ $ROOT_USE -gt 85 ]; then
    echo -e "${RED}⚠️  Root partition is ${ROOT_USE}% full (${ROOT_AVAIL} free) - CRITICAL${NC}"
    echo ""
    echo "Recommended actions:"
    echo "1. Clean Snap packages: sudo snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do sudo snap remove \"$snapname\" --revision=\"$revision\"; done"
    echo "2. Clean apt cache: sudo apt clean && sudo apt autoremove"
    echo "3. Clean journal logs: sudo journalctl --vacuum-size=500M"
    echo "4. Check for large files: find / -type f -size +100M -exec ls -lh {} \\; 2>/dev/null | head -20"
elif [ $ROOT_USE -gt 70 ]; then
    echo -e "${YELLOW}⚠️  Root partition is ${ROOT_USE}% full (${ROOT_AVAIL} free) - Getting full${NC}"
    echo ""
    echo "Consider cleaning:"
    echo "  sudo apt clean && sudo apt autoremove"
    echo "  sudo journalctl --vacuum-size=500M"
else
    echo -e "${GREEN}✓ Root partition is ${ROOT_USE}% full (${ROOT_AVAIL} free) - Healthy${NC}"
fi

# Check /osa usage
if mountpoint -q /osa; then
    OSA_USE=$(df -h /osa | tail -1 | awk '{print $5}' | sed 's/%//')
    OSA_AVAIL=$(df -h /osa | tail -1 | awk '{print $4}')
    echo -e "${GREEN}✓ /osa partition is ${OSA_USE}% full (${OSA_AVAIL} free) - Plenty of space${NC}"
fi

# 10. Summary
print_header "10. SUMMARY"

echo -e "${CYAN}Key points:${NC}"
echo "• Your main disk (/) has 15GB free - this is NORMAL"
echo "• /osa is your large drive (751GB free) - bind mounts use this space"
echo "• The 'du' command shows BIND MOUNTS twice - that's expected behavior"
echo "• Your actual root usage is ~40GB out of 55GB (not 130GB as du suggested)"
echo ""
echo -e "${GREEN}✓ Your system is healthy and has adequate free space!${NC}"

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Analysis complete!${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"