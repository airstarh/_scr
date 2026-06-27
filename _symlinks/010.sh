#!/usr/bin/env bash

set -euo pipefail

SWAP_FILE="/swapfile"

if [ ! -f "\$SWAP_FILE" ]; then
    echo "Файл \$SWAP_FILE не найден. Завершаем работу."
    exit 0
fi

echo "Обнаружен swap-файл: \$SWAP_FILE"

# Отключаем swap для конкретного файла
if sudo swapoff "\$SWAP_FILE"; then
    echo "Swap-файл успешно отключен."
else
    echo "Не удалось отключить swap-файл. Проверьте права или состояние системы."
    exit 1
fi

# Создаем резервную копию fstab
sudo cp /etc/fstab /etc/fstab.bak.\$(date +%F-%H%M%S)

# Удаляем из fstab только строку, содержащую именно /swapfile
# Используем якоря и экранирование, чтобы не затронуть другие файлы (например, /osa/swapfile)
if sudo sed -i '/^[[:space:]]*\/swapfile[[:space:]]/d' /etc/fstab; then
    echo "Запись о swap-файле удалена из /etc/fstab."
else
    echo "Не удалось отредактировать /etc/fstab. Проверьте файл вручную."
fi

# Проверка: убеждаемся, что файл все еще существует (мы его не удаляли), но не активен
if [ -f "\$SWAP_FILE" ]; then
    echo "Файл \$SWAP_FILE сохранен на диске, но отключен."
else
    echo "Файл \$SWAP_FILE не найден (возможно, был удален ранее)."
fi

# Финальная проверка статуса swap
echo "Текущий статус swap:"
swapon --show
