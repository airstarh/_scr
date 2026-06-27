#!/usr/bin/env bash
set -e

# Остановить службу Apache2 (если запущена)
systemctl stop apache2 2>/dev/null || true

# Полностью удалить Apache2 и связанные пакеты, включая конфиги
apt purge -y apache2 apache2-bin apache2-data apache2-utils 2>/dev/null || true

# Удалить оставшиеся неиспользуемые зависимости
apt autoremove -y

# (Опционально) Удалить директории с конфигами и логами, если остались
rm -rf /etc/apache2 /var/log/apache2 2>/dev/null || true

echo "Apache2 stopped and uninstalled."
