#!/bin/bash

echo "=== Поиск USB-устройств с ошибкой -71 (только свежие логи) ==="

# Очищаем буфер dmesg (нужны права root)
echo "Очищаем буфер ядра для новых логов..."
sudo dmesg -C

# Ждём немного и просим ядро выдать базовую информацию — это «прогреет» логи
sleep 2
sudo dmesg > /dev/null

echo "Мониторинг в течение 30 секунд: подключите проблемное USB-устройство..."
echo "(Если ошибка -71 жива, она появится в логах за это время)"

# Запускаем мониторинг dmesg в фоновом режиме на 30 сек: ищем ошибки -71 и сразу записываем
sudo timeout 30s dmesg --follow | grep -i "error.*-71" > /tmp/usb_error_71_fresh.log &

# PID фонового процесса, чтобы потом его убить, если нужно
follow_pid=$!

# Ждём 30 секунд — дайте системе время поймать ошибку
sleep 30

# Останавливаем фоновый мониторинг (если он ещё бежит)
kill $follow_pid 2>/dev/null || true

# Читаем то, что успели поймать
error_lines=$(cat /tmp/usb_error_71_fresh.log 2>/dev/null)

# Убираем временный файл
rm -f /tmp/usb_error_71_fresh.log

if [ -z "$error_lines" ]; then
    echo "Ошибки USB -71 не зафиксированы за период мониторинга."
    exit 0
fi

echo "$error_lines" | while read -r line; do
    # Извлекаем идентификатор устройства (например, "1-4" из "usb 1-4")
    device_id=$(echo "$line" | grep -oP 'usb\s+\K[0-9]+-[0-9]+' || echo "")
    if [ -n "$device_id" ]; then
        echo "--- Обнаружена ошибка для устройства $device_id ---"
        echo "Лог: $line"

        # Ищем это устройство в lsusb
        lsusb_match=$(lsusb | grep -oP "Bus\s+\d+\s+Device\s+\d+.*$device_id.*")
        if [ -n "$lsusb_match" ]; then
            echo "В lsusb: $lsusb_match"
        else
            echo "В lsusb устройство не найдено (возможно, не прошло инициализацию)."
        fi

        # Пытаемся получить более подробную информацию через usb-devices
        echo "Детали из usb-devices:"
        usb-devices | grep -A 5 -B 5 "$device_id" | head -20
        echo ""
    fi
done

echo "Поиск завершён."
