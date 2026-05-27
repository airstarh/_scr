#!/bin/bash

echo "=== Bluetooth & Mouse Fix (Input Remapper SAFE) ==="
echo "Timestamp: $(date)"
echo

# 1. Останавливаем только явно мешающие процессы (оставляем input-remapper)
echo "[1/6] Stopping interfering processes (leaving input-remapper active)..."
killall systemsettings 2>/dev/null
killall obexd 2>/dev/null
echo "  Done."

# 2. Перезапускаем Bluetooth
echo "[2/6] Restarting Bluetooth service..."
sudo systemctl restart bluetooth
echo "  Done."

# 3. Настройки энергосбережения Bluetooth
echo "[3/6] Adjusting Bluetooth power settings..."
echo 1 | sudo tee /sys/module/bluetooth/parameters/disable_ertm > /dev/null 2>&1
echo "  disable_ertm set to 1"

# 4. Перезагружаем драйвер
echo "[4/6] Reloading Bluetooth driver..."
sudo modprobe -r btusb 2>/dev/null
sudo modprobe btusb
echo "  Driver reloaded."

# 5. Проверяем состояние адаптера
echo "[5/6] Verifying Bluetooth adapter status..."
if ! hciconfig | grep -q "RUNNING"; then
    echo "  ERROR: Bluetooth adapter is not running"
    exit 1
fi
echo "  Adapter is UP and RUNNING"

# 6. Применяем настройку для уменьшения задержек мыши (совместимо с input-remapper)
echo "[6/6] Applying mouse report interval tweak..."
echo 'options hid_logitech_hidpp report_interval=8' | sudo tee /etc/modprobe.d/hid-logitech.conf > /dev/null 2>&1
echo "  Tweak applied: reduced report interval for Logitech HID++"

echo
echo "✅ Script completed. Input Remapper was preserved."
echo "Please test your mouse movement and Bluetooth scanning."
echo "If problems persist, run the following for diagnostics:"
echo "  sudo sysctl -w kernel.dmesg_restrict=0"
echo "  dmesg | grep -i -E '(hid|logitech|bluetooth)' | tail -50"
echo "=================================================="
