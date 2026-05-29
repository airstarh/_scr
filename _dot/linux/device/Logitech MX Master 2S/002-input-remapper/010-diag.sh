#!/bin/bash

echo "========================================="
echo "Input Remapper & Mouse Diagnostic Report"
echo "========================================="
echo ""

echo "--- 1. Input Remapper Version ---"
apt list --installed 2>/dev/null | grep input-remapper
echo ""

echo "--- 2. Input Remapper Service Status ---"
sudo systemctl status input-remapper --no-pager -l
echo ""

echo "--- 3. Recent Service Logs (last 50 lines) ---"
sudo journalctl -u input-remapper -n 50 --no-pager
echo ""

echo "--- 4. Current Session Type ---"
echo $XDG_SESSION_TYPE
echo ""

echo "--- 5. Kernel Version ---"
uname -r
echo ""

echo "--- 6. Logitech Kernel Modules ---"
lsmod | grep -E "(logitech|hid_logitech)" || echo "None found"
echo ""

echo "--- 7. USB Devices (Logitech) ---"
lsusb | grep -i logitech
echo ""

echo "--- 8. Recent Kernel Messages (last 30 lines) ---"
dmesg | tail -30
echo ""

echo "--- 9. Mouse/Input Devices ---"
xinput list 2>/dev/null || echo "xinput not available (try: sudo apt install xinput)"
echo ""

echo "--- 10. Bluetooth Status (if applicable) ---"
systemctl status bluetooth --no-pager -l 2>/dev/null | head -5 || echo "Bluetooth not active"
echo ""

echo "--- 11. USB Autosuspend Status ---"
cat /sys/module/usbcore/parameters/autosuspend 2>/dev/null || echo "Not available"
echo ""

echo "--- 12. Running Input Remapper Processes ---"
ps aux | grep -E "(input-remapper|key-mapper)" | grep -v grep
echo ""

echo "========================================="
echo "Diagnostic complete. Please share all output above."
echo "========================================="