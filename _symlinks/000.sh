#!/bin/bash

TARGET="w7x64_HDA"
LOCATIONS=("/osa" "/home/qqq")
mapfile -d $'\0' FOUND_FILES < <(find "${LOCATIONS[@]}" -type f -iname "*${TARGET}*" -print0 2>/dev/null)
[[ ${#FOUND_FILES[@]} -gt 0 ]] && printf '%s\n' "${FOUND_FILES[@]}" || echo "Файлы не найдены"
