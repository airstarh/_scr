#!/bin/bash

# chmod 700 ~/.ssh
# chmod 600 ~/.ssh/001
# chmod 644 ~/.ssh/001.pub
borg_ssh() {
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

    ### eval "$(ssh-agent -s)"
    # 001 is the primary general-purpose SSH key: bbb, sss, ttt, aaa_codex, and other default SSH work.
    ssh-add ~/.ssh/001
    # 1378862
    ssh-add ~/.ssh/002
    # 003 is used for xxx and GitHub account airstarh.
    ssh-add ~/.ssh/003
    # 1234
    ssh-add ~/.ssh/004
}

borg_ssh_sss() {
    ssh sss
}

borg_sshfs_sss() {
    sshfs sss:/home/sewa/_A001/rep/ALINA_BE/ /mnt/sshfs/sss/ \
        -o reconnect \
        -o noatime
}


borg_ssh_bbb(){
    ssh bbb
}

borg_sshfs_bbb() {
    sshfs bbb:/mnt \
        /mnt/sshfs/bbb \
        -o reconnect \
        -o noatime

    sshfs bbb:/home/qqq \
        /mnt/sshfs/bbb-home-qqq \
        -o reconnect \
        -o noatime
}

borg_sshfs_xxx() {
    sshfs xxx:/mnt/ncoder-ai \
        /mnt/sshfs/xxx/nvme \
        -o reconnect \
        -o noatime

    sshfs xxx:/home/qqq \
        /mnt/sshfs/xxx/home-qqq \
        -o reconnect \
        -o noatime
}

aaa_codex() {
    local local_dir="$PWD"
    local remote_dir
    local mount_source
    local mount_target
    local session_hash
    local session_name
    local codex_command
    local tmux_command
    local remote_command

    case "$local_dir" in
        /home/qqq)
            remote_dir=/mnt/sshfs/xxx/home-qqq
            mount_source=xxx:/home/qqq
            mount_target=/mnt/sshfs/xxx/home-qqq
            ;;
        /home/qqq/*)
            remote_dir="/mnt/sshfs/xxx/home-qqq${local_dir#/home/qqq}"
            mount_source=xxx:/home/qqq
            mount_target=/mnt/sshfs/xxx/home-qqq
            ;;
        /mnt/ncoder-ai)
            remote_dir=/mnt/sshfs/xxx/nvme
            mount_source=xxx:/mnt/ncoder-ai
            mount_target=/mnt/sshfs/xxx/nvme
            ;;
        /mnt/ncoder-ai/*)
            remote_dir="/mnt/sshfs/xxx/nvme${local_dir#/mnt/ncoder-ai}"
            mount_source=xxx:/mnt/ncoder-ai
            mount_target=/mnt/sshfs/xxx/nvme
            ;;
        /srv/_v)
            remote_dir=/mnt/sshfs/xxx/nvme/_v
            mount_source=xxx:/mnt/ncoder-ai
            mount_target=/mnt/sshfs/xxx/nvme
            ;;
        /srv/_v/*)
            remote_dir="/mnt/sshfs/xxx/nvme/_v${local_dir#/srv/_v}"
            mount_source=xxx:/mnt/ncoder-ai
            mount_target=/mnt/sshfs/xxx/nvme
            ;;
        *)
            printf 'aaa_codex: current xxx directory is outside the configured mounts: %s\n' \
                "$local_dir" >&2
            return 1
            ;;
    esac

    session_hash=$(printf '%s' "$remote_dir" | sha256sum | cut -c1-12) || return 1
    session_name="codex-xxx-$session_hash"

    printf -v codex_command \
        'source /home/qqq/.nvm/nvm.sh; exec codex --dangerously-bypass-approvals-and-sandbox --no-daemon -C %q' \
        "$remote_dir"
    printf -v tmux_command 'bash -lc %q' "$codex_command"
    printf -v remote_command \
        'set -e; mkdir -p %q; if ! mountpoint -q %q; then sshfs %q %q -o reconnect -o noatime -o IdentityFile=/home/qqq/.ssh/001 -o IdentitiesOnly=yes -o BatchMode=yes; fi; test -d %q; exec tmux new-session -A -s %q -c %q %q' \
        "$mount_target" \
        "$mount_target" \
        "$mount_source" \
        "$mount_target" \
        "$remote_dir" \
        "$session_name" \
        "$remote_dir" \
        "$tmux_command"

    printf 'aaa_codex: xxx directory: %s\n' "$local_dir"
    printf 'aaa_codex: aaa workspace: %s\n' "$remote_dir"
    printf 'aaa_codex: tmux session: %s\n' "$session_name"

    ssh -t \
        -i /home/qqq/.ssh/001 \
        -o IdentitiesOnly=yes \
        -o BatchMode=yes \
        qqq@192.168.1.47 \
        "$remote_command"
}

