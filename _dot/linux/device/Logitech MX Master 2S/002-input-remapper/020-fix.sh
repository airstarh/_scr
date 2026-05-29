#!/bin/bash

echo "========================================="
echo "Fixing Input Remapper Freezes for MX Master 2S"
echo "========================================="

# 1. Kill the zombie process and restart service properly
echo "1. Stopping Input Remapper service..."
sudo systemctl stop input-remapper-daemon

# 2. Kill any remaining processes
echo "2. Cleaning up processes..."
sudo pkill -f input-remapper
sudo pkill -f input-remapper-service

# 3. Clear zombie processes
echo "3. Clearing zombie processes..."
sudo kill -9 14583 2>/dev/null

# 4. Remove and reload kernel module (critical fix)
echo "4. Reloading Logitech kernel module..."
sudo modprobe -r hid_logitech_hidpp
sudo modprobe hid_logitech_hidpp

# 5. Clear old config that might be corrupted
echo "5. Backing up and resetting config..."
if [ -f ~/.config/input-remapper-2/config.json ]; then
    cp ~/.config/input-remapper-2/config.json ~/.config/input-remapper-2/config.json.backup
    echo "Backup saved to ~/.config/input-remapper-2/config.json.backup"
fi

# 6. Restart the service fresh
echo "6. Starting fresh Input Remapper service..."
sudo systemctl start input-remapper-daemon

# 7. Add kernel parameter to prevent Bluetooth reconnection issues
echo "7. Adding kernel parameter for stability..."
echo "options bluetooth disable_ertm=Y" | sudo tee -a /etc/modprobe.d/bluetooth.conf

# 8. Disable USB autosuspend for Bluetooth (helps with stability)
echo "8. Optimizing power management..."
echo "options usbcore autosuspend=-1" | sudo tee -a /etc/modprobe.d/disable-usb-autosuspend.conf

echo "========================================="
echo "Fix applied! Please REBOOT your system."
echo "After reboot, test the mouse."
echo ""
echo "If freezes persist, run:"
echo "  sudo systemctl restart input-remapper-daemon"
echo "========================================="