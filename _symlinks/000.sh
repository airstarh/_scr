#!/bin/bash

echo "Оптимизация журналирования для максимальной производительности..."

if [ "$EUID" -ne 0 ]; then
    echo "Ошибка: запустите скрипт с sudo"
    exit 1
fi

CONFIG_FILE="/etc/systemd/journald.conf"

# Создаём резервную копию
cp "$CONFIG_FILE" "$CONFIG_FILE.perf_backup_$(date +%Y%m%d_%H%M%S)"
echo "Создана резервная копия: $CONFIG_FILE.perf_backup_*"

# Настройки для максимальной производительности
{
    echo "# Настроено для максимальной производительности: минимум I/O, только критические сообщения"
    echo "Storage=volatile"           # Логи только в RAM, не пишутся на диск
    echo "SystemMaxUse=50M"         # Максимум 50 МБ в RAM (достаточно для отладки, но не перегружает память)
    echo "RuntimeMaxUse=50M"       # Аналогично для runtime-части
    echo "SystemKeepFree=100M"     # Резерв свободного места
    echo "RateLimitIntervalSec=10s" # Более агрессивное подавление дубликатов
    echo "RateLimitBurst=100"      # Разрешено только 100 сообщений за интервал
    echo "MaxLevelStore=err"        # Только ошибки (err), критические (crit) и выше
    echo "MaxLevelSyslog=err"       # То же для syslog-совместимых приложений
    echo "SyncIntervalSec=5min"    # Реже синхронизируем данные (если вдруг что-то всё же пишется на диск)
    echo "Compress=no"              # Отключаем сжатие — экономит CPU
    echo "Seal=no"                 # Отключаем криптографическую защиту логов
} > "$CONFIG_FILE"

echo "Конфигурация записана в $CONFIG_FILE"

# Перезапускаем journald
echo "Перезапуск systemd-journald..."
systemctl restart systemd-journald

# Очищаем старые дисковые журналы (если они есть)
echo "Очистка дисковых журналов..."
journalctl --vacuum-time=1s

# Выводим краткий отчёт
echo "=== Настройки применены для максимальной производительности ==="
echo "Хранение: $(grep Storage "$CONFIG_FILE")"
echo "Максимальный объём: $(grep SystemMaxUse "$CONFIG_FILE")"
echo "Уровень логирования: $(grep MaxLevelStore "$CONFIG_FILE")"
echo "Подавление дубликатов: $(grep RateLimit "$CONFIG_FILE")"

echo "Готово. Система теперь тратит минимум ресурсов на журналирование."
