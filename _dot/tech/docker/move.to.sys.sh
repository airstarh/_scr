#! /bin/bash

DOCKER_NEW_ROOT="/mnt/d1001/dockersys/docker"
CONTAINERD_NEW_ROOT="/mnt/d1001/dockersys/containerd"

sudo systemctl stop docker.socket docker containerd

sudo mkdir -p "$DOCKER_NEW_ROOT"
sudo mkdir -p "$CONTAINERD_NEW_ROOT"

### Paths:
### dockersys
###     docker (/var/lib/docker)
sudo rsync -aHAX --info=progress2 /var/lib/docker/ "$DOCKER_NEW_ROOT/"

###     containerd (/var/lib/containerd)
sudo rsync -aHAX --info=progress2 /var/lib/containerd/ "$CONTAINERD_NEW_ROOT/"
###
### Configs:
### /etc/docker/daemon.json
###     "data-root": "$DOCKER_NEW_ROOT"
### /etc/containerd/config.toml
###     root = "$CONTAINERD_NEW_ROOT"
###
##################################################

##################################################
sudo systemctl start docker
