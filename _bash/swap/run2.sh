#!/bin/bash

# Add SSD Swap File Script - 8GB at /swapfile
# Run with sudo: sudo ./add_ssd_swap.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SSD_SWAP="/swapfile"
SSD_SIZE_GB=8
SSD_PRIORITY=10  # Higher priority than HDD

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[ERROR]${NC} This script must be run as root (use sudo)"
    exit 1
fi

echo -e "${GREEN}[INFO]${NC} Adding 8GB SSD swap file at ${SSD_SWAP}"

# Check available SSD space (root partition)
AVAILABLE_SPACE=$(df -BG / | tail -1 | awk '{print $4}' | sed 's/G//')
if [[ $AVAILABLE_SPACE -lt $((SSD_SIZE_GB + 5)) ]]; then
    echo -e "${RED}[ERROR]${NC} Only ${AVAILABLE_SPACE}GB free on SSD. Need at least $((SSD_SIZE_GB + 5))GB"
    echo "Your 50GB SSD is getting full. Consider using 4GB or 2GB instead."
    exit 1
fi

echo -e "${GREEN}[INFO]${NC} Available SSD space: ${AVAILABLE_SPACE}GB"

# Check if swap file already exists
if [[ -f "$SSD_SWAP" ]]; then
    echo -e "${YELLOW}[WARNING]${NC} Swap file already exists at ${SSD_SWAP}"
    
    # Check if it's currently active
    if swapon --show | grep -q "$SSD_SWAP"; then
        echo -e "${YELLOW}[WARNING]${NC} Disabling existing SSD swap..."
        swapoff "$SSD_SWAP" 2>/dev/null || true
    fi
    
    echo -e "${YELLOW}[WARNING]${NC} Removing existing swap file..."
    rm -f "$SSD_SWAP"
fi

# Create swap file
echo -e "${GREEN}[INFO]${NC} Creating ${SSD_SIZE_GB}GB swap file on SSD..."
if fallocate -l ${SSD_SIZE_GB}G "$SSD_SWAP" 2>/dev/null; then
    echo -e "${GREEN}[INFO]${NC} Swap file created with fallocate (fast)"
else
    echo -e "${YELLOW}[WARNING]${NC} fallocate failed, using dd (slower)..."
    dd if=/dev/zero of="$SSD_SWAP" bs=1M count=$((SSD_SIZE_GB * 1024)) status=progress
fi

# Set proper permissions
echo -e "${GREEN}[INFO]${NC} Setting permissions..."
chmod 600 "$SSD_SWAP"

# Format as swap
echo -e "${GREEN}[INFO]${NC} Formatting as swap..."
mkswap "$SSD_SWAP"

# Activate swap with higher priority (will be used before HDD)
echo -e "${GREEN}[INFO]${NC} Activating SSD swap with priority ${SSD_PRIORITY}..."
swapon -p $SSD_PRIORITY "$SSD_SWAP"

# Remove any existing entry from fstab
sed -i '\#/swapfile#d' /etc/fstab

# Add to fstab for persistence
echo "$SSD_SWAP none swap sw,pri=${SSD_PRIORITY} 0 0" >> /etc/fstab

# ============================================
# Verification
# ============================================
echo -e "\n${GREEN}[INFO]${NC} Current swap status:"
swapon --show

echo -e "\n${GREEN}[INFO]${NC} Swap summary:"
free -h

echo -e "\n${GREEN}[SUCCESS]${NC} 8GB SSD swap added successfully!"
echo -e "${GREEN}[INFO]${NC} SSD swap file: ${SSD_SWAP} (8GB, priority ${SSD_PRIORITY})"
echo -e "${GREEN}[INFO]${NC} Your existing HDD swap remains active with lower priority"

# Show which swap will be used first
echo -e "\n${GREEN}[INFO]${NC} Swap priority order (higher number = used first):"
swapon --show=NAME,PRIO,TYPE 2>/dev/null | awk 'NR==1 {print "  " $1 " (priority: " $2 ")"} NR>1 {print "  " $1 " (priority: " $2 ")"}' | sort -k3 -rn

echo -e "\n${YELLOW}[NOTE]${NC} SSD swap file size: $(ls -lh $SSD_SWAP | awk '{print $5}')"
echo -e "${YELLOW}[NOTE]${NC} For better SSD longevity, consider lowering swappiness:"
echo "  sudo sysctl vm.swappiness=10"