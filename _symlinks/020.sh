#!/bin/bash

echo "=== System & Bluetooth Discovery Report ==="
echo "Timestamp: $(date)"
echo "Host: $(hostname)"
echo "OS: $(lsb_release -is) $(lsb_release -rs) ($(uname -r))"
echo

echo "--- lsusb (all devices) ---"
lsusb
echo

echo "--- lsusb Bluetooth class (Class=e0) ---"
lsusb -v 2>/dev/null | grep -A5 -B2 -i "Class=e0" | grep -E "(idVendor|idProduct|iManufacturer|iProduct|bDeviceClass)" || echo "(no Bluetooth class devices found)"
echo

echo "--- lspci (network/wireless) ---"
lspci -nn | grep -i -E "(network|wireless|realtek|10ec)" || echo "(no relevant PCI devices)"
echo

echo "--- bluetoothctl info ---"
bluetoothctl list 2>/dev/null || echo "(bluetoothctl not available)"
bluetoothctl show 2>/dev/null | grep -E "(Name|Alias|Address|Manufacturer|Modalias|Class|Powered)" || echo "(no adapter info)"
echo

echo "--- hciconfig ---"
hciconfig -a 2>/dev/null || echo "(hciconfig not available)"
echo

echo "--- Kernel messages (dmesg, Bluetooth/RTL) ---"
dmesg | grep -i -A3 -B3 -E "(bluetooth|rtk|realtek|hci|firmware|usb|0bda|1d6b)" | tail -n 100
echo

echo "--- Firmware files (Realtek/BT) ---"
find /lib/firmware -path "*rtl*" -o -name "*bt*" -type f 2>/dev/null | sort