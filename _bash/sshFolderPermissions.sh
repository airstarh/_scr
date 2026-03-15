sshFolderPermissions() {
    local ssh_dir="$HOME/.ssh"

    # Проверяем, существует ли каталог ~/.ssh
    if [[ ! -d "$ssh_dir" ]]; then
        echo "Ошибка: каталог $ssh_dir не существует." >&2
        return 1
    fi

    # Устанавливаем права 700 для каталога ~/.ssh
    chmod 700 "$ssh_dir"
    echo "Установлены права 700 для каталога: $ssh_dir"

    # Устанавливаем права 600 для всех файлов без расширения
    find "$ssh_dir" -maxdepth 1 -type f ! -name "*.*" -exec chmod 600 {} \;
    echo "Установлены права 600 для файлов без расширения в: $ssh_dir"

    # Устанавливаем права 644 для всех файлов с расширением .pub
    find "$ssh_dir" -maxdepth 1 -type f -name "*.pub" -exec chmod 644 {} \;
    echo "Установлены права 644 для файлов с расширением .pub в: $ssh_dir"
}
