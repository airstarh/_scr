#!/bin/bash

# Имя искомого файла
TARGET_FILE="w7x64_HDA.img"

echo "Поиск файла '$TARGET_FILE' в системе..."

# Поиск файла начиная с корня; показываем только первый найденный результат (если нужен один)
FOUND=$(find / -type f -iname "*${TARGET_SUBSTRING}*" 2>/dev/null | head -n 1)

if [[ -n "$FOUND" ]]; then
    echo "Файл найден: $FOUND"
else
    echo "Файл '$TARGET_FILE' не найден."
fi
