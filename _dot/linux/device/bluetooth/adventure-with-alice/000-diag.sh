#!/bin/bash

echo "=== USB AND BLUETOOTH DIAGNOSTIC SCRIPT ==="
echo "Timestamp: $(date)"
echo

echo "[1/8] USB DEVICES LIST"
lsusb
echo

echo "[2/8] KERNEL USB LOGS (last 50 lines with USB/Bluetooth keywords)"
dmesg | grep -i -E "(usb|bluetooth|hid|input|uhci|xhci|cannot get freq)" | tail -n 50
echo

echo "[3/8] BLUETOOTH DEVICES AND STATUS"
bluetoothctl devices
echo "---"
bluetoothctl show
echo

echo "[4/8] USB PORTS STATUS"
ls /sys/bus/usb/devices/ | grep -E "^usb[0-9]+" | while read port; do
    echo "Port $port:"
    cat /sys/bus/usb/devices/$port/power/control 2>/dev/null || echo "  (no power control info)"
    echo
done

echo "[5/8] SUSPEND SETTINGS FOR USB"
autosuspend_val=$(cat /sys/module/usbcore/parameters/autosuspend 2>/dev/null)
if [ -z "$autosuspend_val" ]; then
    autosuspend_val="not set"
fi
echo "USB autosuspend parameter: $autosuspend_val"

udev_rules=$(grep -r "autosuspend" /etc/udev/rules.d/ 2>/dev/null | head -n 3)
if [ -z "$udev_rules" ]; then
    udev_rules="no UDev rules found"
fi
echo "Global USB autosuspend: $udev_rules"
echo

echo "[6/8] POWER MANAGEMENT FOR USB DEVICES"
find /sys/bus/usb/devices/ -name "power/control" 2>/dev/null | while read file; do
    device_path=$(dirname "$file")
    device_name=$(basename "$device_path")
    control_value=$(cat "$file" 2>/dev/null)
    echo "Device $device_name: power/control = $control_value"
done
echo

echo "[7/8] SYSTEMD SERVICES RELATED TO USB/BLUETOOTH"
systemctl list-units --type=service | grep -i -E "(bluetooth|usb|hid)"
echo

echo "[8/8] OVER-CURRENT DETECTION AND POWER ISSUES"
dmesg | grep -i "over-current" | tail -n 10
if dmesg | grep -i "over-current" > /dev/null; then
    echo "WARNING: Over-current events detected!"
else
    echo "No over-current events found."
fi
echo

echo "[9/8] BLUETOOTH ADAPTER FIRMWARE STATUS"
dmesg | grep -i "rtl" | grep -i "fw\|firmware" | tail -n 20
echo

echo "=== DIAGNOSTIC COMPLETE ==="
