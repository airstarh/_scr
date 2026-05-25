#!/bin/bash

# Настраиваемые параметры — меняйте их под себя
TARGET_SUBSTRING="w11"
LOCALES=("/osa" "/home/qqq")  # ~ заменён на полный путь

# Массив для результатов
FOUND_FILES=()

echo "Поиск файлов, содержащих '$TARGET_SUBSTRING', в каталогах: ${LOCALES[*]}..."

# Ищем файлы: используем -print0 и read -d $'\0' для надёжности (корректно работает с пробелами и спецсимволами в именах)
while IFS= read -r -d $'\0'; do
    FOUND_FILES+=("$REPLY")
done < <(find "${LOCALES[@]}" -type f -iname "*${TARGET_SUBSTRING}*" -print0 2>/dev/null)

# Выводим результат
if [[ ${#FOUND_FILES[@]} -gt 0 ]]; then
    echo "Найдено ${#FOUND_FILES[@]} файлов:"
    for file in "${FOUND_FILES[@]}"; do
        echo "  $file"
    done
else
    echo "Файлы с подстрокой '$TARGET_SUBSTRING' не найдены."
fi
