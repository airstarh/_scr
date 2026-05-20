#!/bin/bash

# Swap File Creation Script - 20GB on HDD at /osa
# Run with sudo: sudo ./create_swap.sh

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SWAP_PATH="/osa/swapfile"
SWAP_SIZE_GB=20

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[ERROR]${NC} This script must be run as root (use sudo)"
    exit 1
fi

echo -e "${GREEN}[INFO]${NC} Creating ${SWAP_SIZE_GB}GB swap file at ${SWAP_PATH}"

# Check if /osa exists
if [[ ! -d "/osa" ]]; then
    echo -e "${RED}[ERROR]${NC} Directory /osa does not exist!"
    echo "Please mount your HDD to /osa first"
    exit 1
fi

# Check available space
AVAILABLE=$(df -BG /osa | tail -1 | awk '{print $4}' | sed 's/G//')
if [[ $AVAILABLE -lt $((SWAP_SIZE_GB + 2)) ]]; then
    echo -e "${RED}[ERROR]${NC} Only ${AVAILABLE}GB available on /osa. Need at least $((SWAP_SIZE_GB + 2))GB"
    exit 1
fi

echo -e "${GREEN}[INFO]${NC} Available space: ${AVAILABLE}GB"

# Disable swap if already using this file
if swapon --show | grep -q "$SWAP_PATH"; then
    echo -e "${YELLOW}[WARNING]${NC} Disabling existing swap at ${SWAP_PATH}"
    swapoff "$SWAP_PATH" 2>/dev/null || true
fi

# Remove existing swap file if present
if [[ -f "$SWAP_PATH" ]]; then
    echo -e "${YELLOW}[WARNING]${NC} Removing existing swap file"
    rm -f "$SWAP_PATH"
fi

# Create swap file using dd (more reliable on HDD)
echo -e "${GREEN}[INFO]${NC} Creating ${SWAP_SIZE_GB}GB swap file (this will take time on HDD)..."
dd if=/dev/zero of="$SWAP_PATH" bs=1M count=$((SWAP_SIZE_GB * 1024)) status=progress

# Set proper permissions
echo -e "${GREEN}[INFO]${NC} Setting permissions..."
chmod 600 "$SWAP_PATH"

# Format as swap
echo -e "${GREEN}[INFO]${NC} Formatting as swap..."
mkswap "$SWAP_PATH"

# Activate swap
echo -e "${GREEN}[INFO]${NC} Activating swap..."
swapon "$SWAP_PATH"

# Remove any existing entry from fstab
echo -e "${GREEN}[INFO]${NC} Updating /etc/fstab..."
sed -i '\#/osa/swapfile#d' /etc/fstab

# Add to fstab for persistence
echo "$SWAP_PATH none swap sw 0 0" >> /etc/fstab

# Verify swap is active
echo -e "${GREEN}[INFO]${NC} Swap created and activated successfully!"
echo ""
echo "Current swap status:"
swapon --show
echo ""
free -h
echo ""
echo -e "${GREEN}[SUCCESS]${NC} 20GB swap file is now active on HDD at /osa/swapfile"
echo "It will persist after reboot (entry added to /etc/fstab)"