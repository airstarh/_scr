#!/bin/bash

# --- Конфигурация ---
DOCKER_NEW_ROOT="/mnt/d1001/docker"
CONTAINERD_NEW_ROOT="/mnt/d1001/containerd"

# Останавливаем сервисы
echo "Останавливаю сервисы..."
sudo systemctl stop docker.socket docker containerd

# Создаём целевые директории
echo "Создаю директории для хранения данных..."
sudo mkdir -p "$DOCKER_NEW_ROOT"
sudo mkdir -p "$CONTAINERD_NEW_ROOT"

# Надёжно перемещаем данные Docker
echo "Перемещаю данные Docker..."
sudo shopt -s dotglob nullglob # Включает обработку скрытых файлов и предотвращает ошибку, если файлов нет
if [ -d /var/lib/docker ]; then
    sudo mv /var/lib/docker/* "$DOCKER_NEW_ROOT/"
fi
sudo shopt -u dotglob nullglob

# Надёжно перемещаем данные containerd
echo "Перемещаю данные containerd..."
sudo shopt -s dotglob nullglob
if [ -d /var/lib/containerd ]; then
    sudo mv /var/lib/containerd/* "$CONTAINERD_NEW_ROOT/"
fi
sudo shopt -u dotglob nullglob

# Удаляем старые пустые директории
echo "Очищаю старые локации..."
sudo rmdir /var/lib/docker 2>/dev/null || true
sudo rmdir /var/lib/containerd 2>/dev/null || true

# Настраиваем Docker
echo "Настраиваю daemon.json для Docker..."
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "data-root": "${DOCKER_NEW_ROOT}"
}
EOF

# Настраиваем containerd
echo "Генерирую и настраиваю config.toml для containerd..."
sudo mkdir -p /etc/containerd
# Правильный способ указать корень при генерации
sudo containerd config default | sudo sed "s|/var/lib/containerd|${CONTAINERD_NEW_ROOT}|g" | sudo tee /etc/containerd/config.toml > /dev/null

# Запускаем сервисы
echo "Запускаю сервисы..."
sudo systemctl start containerd
sudo systemctl start docker

# Проверка
echo "Проверка Docker:"
sudo docker info | grep "Docker Root Dir"
echo ""
echo "Содержимое новой директории Docker:"
sudo ls -la "$DOCKER_NEW_ROOT" | head -n 5
