#!/bin/bash

echo "=== Bluetooth Adapter Information ==="

# Check for hciconfig (classic tool)
if command -v hciconfig &> /dev/null; then
    echo -e "\n--- hciconfig output ---"
    hciconfig
else
    echo "hciconfig not available (try installing bluez package)"
fi

# Check for bluetoothctl (modern tool)
if command -v bluetoothctl &> /dev/null; then
    echo -e "\n--- bluetoothctl devices and adapter ---"
    # Show paired/connected devices
    bluetoothctl devices
    # Show adapter info (name, address, etc.)
    bluetoothctl list
    # Try to show current adapter details (if powered)
    bluetoothctl show
else
    echo "bluetoothctl not available (install bluez package)"
fi

# Alternative: use dbus to query adapter (if bluetoothd is running)
echo -e "\n--- DBus adapter properties ---"
dbus-send --system --dest=org.bluez --print-reply /org/bluez/hci0 org.freedesktop.DBus.Properties.GetAll string:org.bluez.Adapter1 2>/dev/null || echo "DBus query failed (adapter may not be hci0 or bluetoothd not running)"

# Kernel level: check for hci devices via sysfs
echo -e "\n--- Kernel (sysfs) info ---"
for hci in /sys/class/bluetooth/hci*; do
    if [[ -d "$hci" ]]; then
        name=$(basename "$hci")
        echo "Adapter: $name"
        address=$(cat "$hci"/address 2>/dev/null)
        echo "  Address: $address"
        # Show power state
        powered=$(cat "$hci"/power/state 2>/dev/null)
        echo "  Powered: $powered"
    fi
done

# Final note
echo -e "\n=== Done ==="
