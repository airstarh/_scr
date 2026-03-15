sshFolderPermissions() {
    local ssh_dir="$HOME/.ssh"

    if [[ ! -d "$ssh_dir" ]]; then
        echo "Ошибка: каталог $ssh_dir не существует." >&2
        return 1
    fi

    chmod 700 "$ssh_dir"
    echo "Установлены права 700 для каталога: $ssh_dir"

    find "$ssh_dir" -maxdepth 1 -type f ! -name "*.*" -exec chmod 600 {} \;
    echo "Установлены права 600 для файлов без расширения в: $ssh_dir"

    find "$ssh_dir" -maxdepth 1 -type f -name "*.private" -exec chmod 600 {} \;
    echo "Установлены права 644 для файлов с расширением .private в: $ssh_dir"

    find "$ssh_dir" -maxdepth 1 -type f -name "*.pub" -exec chmod 644 {} \;
    echo "Установлены права 644 для файлов с расширением .pub в: $ssh_dir"
}
