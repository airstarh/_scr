#!/bin/bash

echo "========================================="
echo "Fixing Input Remapper - Preserving Solaar"
echo "========================================="

# 1. Stop services in correct order
echo "1. Stopping services..."
sudo systemctl stop input-remapper-daemon
sudo pkill -f input-remapper

# 2. Force clear the zombie process
echo "2. Cleaning zombie processes..."
sudo kill -9 14583 2>/dev/null

# 3. Remove only the conflicting kernel module
echo "3. Reloading Bluetooth HID module..."
sudo modprobe -r hid_logitech_hidpp
sleep 2
sudo modprobe hid_logitech_hidpp

# 4. Restart Bluetooth (keeps pairing)
echo "4. Restarting Bluetooth..."
sudo systemctl restart bluetooth
sleep 3

# 5. Restart Solaar (important - before Input Remapper)
echo "5. Restarting Solaar..."
pkill solaar 2>/dev/null
solaar --window=hide &
sleep 2

# 6. Start Input Remapper fresh
echo "6. Starting Input Remapper..."
sudo systemctl start input-remapper-daemon

# 7. Verify no zombie process
echo "7. Checking for zombie processes..."
ps aux | grep -E "input-remapper.*defunct" | grep -v grep
if [ $? -eq 0 ]; then
    echo "⚠️  Zombie still present - may need reboot"
else
    echo "✅ No zombie processes found"
fi

echo ""
echo "========================================="
echo "Fix applied. Test the mouse now."
echo "If still freezing, reboot when possible."
echo "========================================="