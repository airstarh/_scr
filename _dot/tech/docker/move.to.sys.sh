#! /bin/bash

NEW__PATH_DOCKER="/mnt/d1001/dockersys/docker"
NEW__PATH_CONTAINERD="/mnt/d1001/dockersys/containerd"

sudo systemctl stop docker.socket docker containerd

sudo mkdir -p "$NEW__PATH_DOCKER"
sudo mkdir -p "$NEW__PATH_CONTAINERD"

### Paths:
### dockersys
###     docker (/var/lib/docker)
sudo rsync -aHAX --info=progress2 /var/lib/docker/ "$NEW__PATH_DOCKER/"

###     containerd (/var/lib/containerd)
sudo rsync -aHAX --info=progress2 /var/lib/containerd/ "$NEW__PATH_CONTAINERD/"
###
### Configs:
### /etc/docker/daemon.json
###     "data-root": "$NEW__PATH_DOCKER"
### /etc/containerd/config.toml
###     root = "$NEW__PATH_CONTAINERD"
###
##################################################

##################################################
sudo systemctl start docker
