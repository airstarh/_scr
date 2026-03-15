sshFolderPermissions() {
    local ssh_dir="$HOME/.ssh"
    local known_hosts="$ssh_dir/known_hosts"
    local config_file="$ssh_dir/config"

    if [[ ! -d "$ssh_dir" ]]; then
        echo "Ошибка: каталог $ssh_dir не существует." >&2
        return 1
    fi

    chmod 700 "$ssh_dir"
    echo "Установлены права 700 для каталога: $ssh_dir"

    find "$ssh_dir" -maxdepth 1 -type f ! -name "*.*" -exec chmod 600 {} \;
    echo "Установлены права 600 для файлов без расширения в: $ssh_dir"

    find "$ssh_dir" -maxdepth 1 -type f -name "*.private" -exec chmod 600 {} \;
    echo "Установлены права 600 для файлов с расширением .private в: $ssh_dir"

    find "$ssh_dir" -maxdepth 1 -type f -name "*.ppk" -exec chmod 600 {} \;
    echo "Установлены права 600 для файлов с расширением .ppk в: $ssh_dir"

    find "$ssh_dir" -maxdepth 1 -type f -name "*.pem" -exec chmod 600 {} \;
    echo "Установлены права 600 для файлов с расширением .pem в: $ssh_dir"

    find "$ssh_dir" -maxdepth 1 -type f -name "*.pub" -exec chmod 644 {} \;
    echo "Установлены права 644 для файлов с расширением .pub в: $ssh_dir"

    # Обработка файла known_hosts
    if [[ -f "$known_hosts" ]]; then
        chmod 644 "$known_hosts"
        echo "Установлены права 644 для файла: $known_hosts"
    else
        echo "Файл $known_hosts не найден, пропускаем установку прав."
    fi

    # Обработка файла config
    if [[ -f "$config_file" ]]; then
        chmod 600 "$config_file"
        echo "Установлены права 600 для файла: $config_file"
    else
        echo "Файл $config_file не найден, пропускаем установку прав."
    fi
}
