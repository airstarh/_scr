sshFolderPermissions() {
    local ssh_dir="$HOME/.ssh"

    if [[ ! -d "$ssh_dir" ]]; then
        echo "Ошибка: каталог $ssh_dir не существует." >&2
        return 1
    fi

    chmod 700 "$ssh_dir"
    echo "700 $ssh_dir"

    find "$ssh_dir" -maxdepth 1 -type f ! -name "*.*" -exec chmod 600 {} \;
    echo "600 *.*"

    find "$ssh_dir" -maxdepth 1 -type f -name "*.private" -exec chmod 600 {} \;
    echo "600 *.private"

    find "$ssh_dir" -maxdepth 1 -type f -name "*.pub" -exec chmod 644 {} \;
    echo "644 *.pub"
}
