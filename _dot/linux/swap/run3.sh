#!/bin/bash

# Restore HDD Swap File Script
# Re-activates existing swap file at /osa/swapFile
# Run with sudo: sudo ./restore_hdd_swap.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

HDD_SWAP="/osa/swapFile"
HDD_PRIORITY=5  # Lower than SSD (which has priority 10)

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[ERROR]${NC} This script must be run as root (use sudo)"
    exit 1
fi

echo -e "${GREEN}[INFO]${NC} Restoring HDD swap file at ${HDD_SWAP}"

# Check if swap file exists
if [[ ! -f "$HDD_SWAP" ]]; then
    echo -e "${RED}[ERROR]${NC} Swap file not found at ${HDD_SWAP}"
    echo "Checking alternative paths..."

    # Check for common variations
    if [[ -f "/osa/swapfile" ]]; then
        HDD_SWAP="/osa/swapfile"
        echo -e "${GREEN}[INFO]${NC} Found swap file at ${HDD_SWAP}"
    elif [[ -f "/osa/swap" ]]; then
        HDD_SWAP="/osa/swap"
        echo -e "${GREEN}[INFO]${NC} Found swap file at ${HDD_SWAP}"
    else
        echo -e "${RED}[ERROR]${NC} No swap file found in /osa/"
        ls -la /osa/ | grep -i swap || echo "No swap files found"
        exit 1
    fi
fi

# Check if swap file is already active
if swapon --show | grep -q "$HDD_SWAP"; then
    echo -e "${YELLOW}[WARNING]${NC} Swap file is already active at ${HDD_SWAP}"
    echo "Current status:"
    swapon --show | grep "$HDD_SWAP"
    exit 0
fi

# Verify it's a valid swap file
echo -e "${GREEN}[INFO]${NC} Verifying swap file..."
if ! sudo blkid "$HDD_SWAP" | grep -q "swap"; then
    echo -e "${YELLOW}[WARNING]${NC} File doesn't appear to be formatted as swap. Re-formatting..."
    sudo mkswap "$HDD_SWAP"
fi

# Check available space on HDD
AVAILABLE_SPACE=$(df -BG /osa | tail -1 | awk '{print $4}' | sed 's/G//')
SWAP_SIZE=$(du -BG "$HDD_SWAP" | cut -f1 | sed 's/G//')
echo -e "${GREEN}[INFO]${NC} Swap file size: ${SWAP_SIZE}GB"
echo -e "${GREEN}[INFO]${NC} Available HDD space: ${AVAILABLE_SPACE}GB"

# Activate the swap file
echo -e "${GREEN}[INFO]${NC} Activating HDD swap with priority ${HDD_PRIORITY}..."
swapon -p $HDD_PRIORITY "$HDD_SWAP"

# Check if already in fstab, if not add it
if ! grep -q "^$HDD_SWAP" /etc/fstab; then
    echo -e "${GREEN}[INFO]${NC} Adding to /etc/fstab for persistence..."
    echo "$HDD_SWAP none swap sw,pri=${HDD_PRIORITY} 0 0" >> /etc/fstab
else
    # Update priority in fstab if needed
    if ! grep -q "pri=" /etc/fstab | grep "$HDD_SWAP"; then
        sed -i "s|^$HDD_SWAP.*$|$HDD_SWAP none swap sw,pri=${HDD_PRIORITY} 0 0|" /etc/fstab
    fi
fi

# Verification
echo -e "\n${GREEN}[INFO]${NC} Current swap status:"
swapon --show

echo -e "\n${GREEN}[SUCCESS]${NC} HDD swap restored successfully!"
echo -e "${GREEN}[INFO]${NC} Both swaps are now active:"

# Show both swaps clearly
echo ""
swapon --show=NAME,SIZE,PRIO | awk 'NR==1 {printf "%-35s %-10s %s\n", "NAME", "SIZE", "PRIORITY"} NR>1 {printf "%-35s %-10s %d\n", $1, $2, $3}'

echo ""
echo -e "${GREEN}[INFO]${NC} Priority order (higher number = used first):"
swapon --show=NAME,PRIO | tail -n +2 | sort -k2 -rn | awk '{print "  - " $1 " (priority: " $2 ")"}'

echo ""
echo -e "${GREEN}[INFO]${NC} Total swap available:"
free -h