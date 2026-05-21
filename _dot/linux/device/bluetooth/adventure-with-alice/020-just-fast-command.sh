#!/!/bin/bash

echo "=== COMPREHENSIVE USB/BLUETOOTH DIAGNOSTIC SCRIPT ==="
echo "Timestamp: $(date)"
echo

echo "[1/9] SYSTEM INFORMATION"
echo "Kernel version: $(uname -r)"
echo "Distribution: $(lsb_release -is 2>/dev/null || echo 'Unknown')"
echo

echo "[2/9] USB DEVICES LIST"
lsusb
echo

echo "[3/9] KERNEL USB LOGS (last 100 lines with critical keywords)"
dmesg | grep -i -E "(usb|bluetooth|hid|input|uhci|xhci|cannot get freq|over-current|firmware)" | tail -n 100
echo

echo "[4/9] BLUETOOTH DEVICES AND STATUS"
bluetoothctl devices
echo "---"
bluetoothctl show
echo

echo "[5/9] USB PORTS STATUS"
ls /sys/bus/usb/devices/ | grep -E "^usb[0-9]+" | while read port; do
    echo "Port $port:"
    cat /sys/bus/usb/devices/$port/power/control 2>/dev/null || echo "  (no power control info)"
    echo
done
echo

echo "[6/9] SUSPEND SETTINGS FOR USB"
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

echo "[7/9] POWER MANAGEMENT FOR USB DEVICES"
find /sys/bus/usb/devices/ -name "power/control" 2>/dev/null | while read file; do
    device_path=$(dirname "$file")
    device_name=$(basename "$device_path")
    control_value=$(caаt "$file" 2>/dev/null)
    echo "Device $device_name: power/control = $control_value"
done
echo

echo "[8/9] OVER-CURRENT DETECTION AND POWER ISSUES"
over_current=$(dmesg | grep -i "over-current" | tail -n 10)
if [ -n "$over_current" ]; then
    echo "WARNING: Over-current events detected!"
    echo "$over_current"
else
    echo "No over-current events found."
fi
echo

echo "[9/9] BLUETOOTH ADAPTER FIRMWARE AND CONNECTION STATUS"
dmesg | grep -i "rtl" | grep -i "fw\|firmware\|version" | tail -n 20
echo "Bluetooth device status:"
hciconfig
echo
echo "=== DIAGNOSTIC COMPLETE ==="
