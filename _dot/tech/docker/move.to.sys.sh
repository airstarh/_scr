#!/bin/bash
set -e

DOCKER_NEW_ROOT="/mnt/d1001/docker"
CONTAINERD_NEW_ROOT="/mnt/d1001/containerd"

sudo systemctl stop docker.socket docker containerd

sudo mkdir -p "$DOCKER_NEW_ROOT"
sudo mkdir -p "$CONTAINERD_NEW_ROOT"

if [ -d /var/lib/docker ]; then
    sudo rsync -aHAX --info=progress2 /var/lib/docker/ "$DOCKER_NEW_ROOT/"
fi

if [ -d /var/lib/containerd ]; then
    sudo rsync -aHAX --info=progress2 /var/lib/containerd/ "$CONTAINERD_NEW_ROOT/"
fi

if [ -f /etc/docker/daemon.json ]; then
    sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak
fi

sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "data-root": "${DOCKER_NEW_ROOT}"
}
EOF

if [ -f /etc/containerd/config.toml ]; then
    sudo cp /etc/containerd/config.toml /etc/containerd/config.toml.bak
    sudo sed -i "s|/var/lib/containerd|${CONTAINERD_NEW_ROOT}|g" /etc/containerd/config.toml
else
    sudo mkdir -p /etc/containerd
    sudo containerd config default | sudo sed "s|/var/lib/containerd|${CONTAINERD_NEW_ROOT}|g" | sudo tee /etc/containerd/config.toml > /dev/null
fi

sudo systemctl start containerd
sudo systemctl start docker

sudo docker info | grep "Docker Root Dir"
