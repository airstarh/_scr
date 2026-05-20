#!/bin/bash

# fix-home-bindmount.sh - Convert /home symlink to bind mount for snap compatibility

set -e  # Stop on error

echo "========================================="
echo "Converting /home from symlink to bind mount"
echo "========================================="

# Check if /home is currently a symlink
if [ ! -L /home ]; then
    echo "ERROR: /home is not a symlink. Current state:"
    ls -ld /home
    exit 1
fi

# Get the target of the symlink
TARGET=$(readlink /home)
echo "Current symlink target: $TARGET"

# Verify target exists
if [ ! -d "$TARGET" ]; then
    echo "ERROR: Target directory $TARGET does not exist!"
    exit 1
fi

echo "Target directory exists and is valid."

# Backup current fstab
echo "Creating backup of /etc/fstab..."
sudo cp /etc/fstab /etc/fstab.backup.$(date +%Y%m%d_%H%M%S)

# Remove the symlink
echo "Removing /home symlink..."
sudo rm /home

# Create empty directory for bind mount
echo "Creating /home directory for bind mount..."
sudo mkdir -p /home

# Add bind mount to fstab if not already present
if ! grep -q "^$TARGET /home none bind" /etc/fstab; then
    echo "Adding bind mount to /etc/fstab..."
    echo "$TARGET /home none bind 0 0" | sudo tee -a /etc/fstab
else
    echo "Bind mount already exists in fstab"
fi

# Mount it
echo "Mounting /home via bind mount..."
sudo mount /home

# Verify
echo ""
echo "========================================="
echo "VERIFICATION:"
echo "========================================="
ls -ld /home
echo ""
echo "Files in your home directory:"
ls -la /home/qqq/ | head -10
echo ""
echo "Testing Firefox..."
firefox --version

echo ""
echo "========================================="
echo "✅ SUCCESS! /home is now a bind mount"
echo "========================================="
echo "Backup of fstab saved to: /etc/fstab.backup.*"
echo ""
echo "You can now run: firefox"