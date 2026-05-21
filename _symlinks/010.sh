#!/bin/bash

echo "=== USB AND BLUETOOTH ISSUE FIX SCRIPT ==="
echo "Running as $(whoami) at $(date)"
echo

# Проверка прав суперпользователя
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run with sudo privileges."
    exit 1
fi

echo "[1/6] Disabling conflicting UDev rules..."
if [ -f /etc/udev/rules.d/99-fix-usb-power.rules ]; then
    mv /etc/udev/rules.d/99-fix-usb-power.rules /etc/udev/rules.d/99-fix-usb-power.rules.backup
    echo "  - Moved 99-fix-usb-power.rules to backup"
else
    echo "  - 99-fix-usb-power.rules not found, skipping"
fi
udevadm control --reload-rules
udevadm trigger
echo "  - Reloaded UDev rules"

echo
echo "[2/6] Disabling USB autosuspend..."
echo -1 | tee /sys/module/usbcore/parameters/autosuspend
current_autosuspend=$(cat /sys/module/usbcore/parameters/autosuspend)
echo "  - Current autosuspend value: $current_autosuspend"

echo
echo "[3/6] Temporarily disconnecting all Bluetooth devices except MX Master 2S..."
bluetoothctl devices | while read line; do
    mac=$(echo "$line" | grep -o -E '([0-9A-F]{2}:){5}[0-9A-F]{2}' | head -1)
    if [ -n "$mac" ] && [ "$mac" != "C3:68:4E:18:16:BD" ]; then
        echo "  - Disconnecting $mac"
        bluetoothctl disconnect "$mac"
    fi
done
echo "  - All other Bluetooth devices disconnected"

echo
echo "[4/6] Restarting Bluetooth service..."
systemctl restart bluetooth.service
echo "  - Bluetooth service restarted"

echo
echo "[5/6] Disabling usb-power-fix service..."
if systemctl is-active --quiet usb-power-fix.service; then
    systemctl stop usb-power-fix.service
    systemctl disable usb-power-fix.service
    echo "  - usb-power-fix.service stopped and disabled"
else
    echo "  - usb-power-fix.service is not active, skipping"
fi

echo
echo "[6/6] Collecting final logs for verification..."
dmesg | grep -i -E "(usb|bluetooth|hid|input)" | tail -n 100 > /tmp/usb-bluetooth-log-after.txt
echo "  - Logs saved to /tmp/usb-bluetooth-log-after.txt"

echo
echo "=== FIX COMPLETE ==="
echo "Please test your Bluetooth mouse stability."
echo "If issues persist, share /tmp/usb-bluetooth-log-after.txt with us."
