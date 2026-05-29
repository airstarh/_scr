#!/bin/bash

# Очистка всех логов в Kubuntu

# Очищаем журналы journald
sudo journalctl --flush --rotate
sudo journalctl --vacuum-time=1s

# Обнуляем текстовые логи в /var/log/ (только файлы с расширением .log)
sudo find /var/log -name "*.log" -type f -exec truncate -s 0 {} \;

# Перезапускаем rsyslog, чтобы сервисы обновили дескрипторы
sudo systemctl restart rsyslog 2>/dev/null || true

echo "Все логи очищены."
