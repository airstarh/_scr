#!/usr/bin/env bash
set -euo pipefail

# Проверка прав root
if [[ $EUID -ne 0 ]]; then
   echo "Этот скрипт нужно запускать от root (через sudo)."
   exit 1
fi

echo ">>> Проверка занятых портов 53..."
ss -tulnp | grep ':53' || true

# Создаем директорию для доп. конфигов systemd-resolved, если нет
mkdir -p /etc/systemd/resolved.conf.d

# Создаем конфиг, отключающий stub-listener (освобождает 127.0.0.53:53 и ::1:53)
cat > /etc/systemd/resolved.conf.d/no-stub-listener.conf <<EOF
[Resolve]
DNSStubListener=no
EOF

echo ">>> Применен конфиг /etc/systemd/resolved.conf.d/no-stub-listener.conf"

# Перечитываем конфиги systemd
systemctl daemon-reload

# Перезапускаем systemd-resolved, чтобы изменения применились
echo ">>> Перезапуск systemd-resolved..."
systemctl restart systemd-resolved

# Ждем пару секунд, чтобы сервис успел пересоздать сокеты
sleep 2

echo ">>> Проверка, освобожден ли порт 53..."
ss -tulnp | grep ':53' || true

# Проверяем, нет ли других процессов на порту 53 (например, dnsmasq от libvirt)
if ss -tulnp | grep -q ':53 '; then
   echo ">>> Внимание: порт 53 всё ещё занят. Проверьте вывод выше."
   echo ">>> Возможно, это dnsmasq от libvirt (192.168.122.1) или другой сервис."
   exit 1
fi

echo ">>> Порт 53 освобожден. Можно запускать docker compose."
