#!/bin/bash
# 866d8b11-e804-41af-9d9c-a99f5bbb025f

set -e

sudo apt update && sudo apt upgrade -y

# Пробуем скачать скрипт установки напрямую с GitHub
curl -Ss https://raw.githubusercontent.com/netdata/netdata/master/packaging/installer/kickstart.sh -o /tmp/netdata-kickstart.sh
if [ $? -ne 0 ]; then
    echo "Failed to download NetData installation script from GitHub" >&2
    exit 1
fi

# Проверяем, что скачали не HTML
if head -c 100 /tmp/netdata-kickstart.sh | grep -qi "<html>"; then
    echo "Error: Downloaded HTML instead of shell script. Check your network, DNS, or proxy settings." >&2
    cat /tmp/netdata-kickstart.sh | head -n 10  # выводим начало файла для диагностики
    rm -f /tmp/netdata-kickstart.sh
    exit 1
fi

# Запускаем установку
bash /tmp/netdata-kickstart.sh
rm -f /tmp/netdata-kickstart.sh

# Ждём немного, чтобы сервис успел зарегистрироваться в systemd
sleep 5

# Пытаемся запустить и включить сервис, если он появился
if systemctl list-unit-files | grep -q netdata.service; then
    sudo systemctl start netdata
    sudo systemctl enable netdata
else
    echo "Warning: netdata.service not found in systemd. Installation may be incomplete." >&2
fi

# Разрешаем порт в UFW, если он установлен
if command -v ufw >/dev/null 2>&1; then
    sudo ufw allow 19999/tcp 2>/dev/null || true
fi

echo "NetData installation completed. Access at http://localhost:19999"
