#! /bin/bash

OLD_PATH_DOCKER="/var/lib/docker"
NEW_PATH_DOCKER="/mnt/d1001/dockersys/docker"
OLD_PATH_CONTAINERD="/var/lib/containerd"
NEW_PATH_CONTAINERD="/mnt/d1001/dockersys/containerd"

sudo systemctl stop docker.socket docker containerd

sudo mkdir -p "$NEW_PATH_DOCKER"
sudo mkdir -p "$NEW_PATH_CONTAINERD"

### Paths:
### dockersys
###     docker (OLD_PATH_DOCKER)
sudo rsync -aHAX --info=progress2 "$OLD_PATH_DOCKER/" "$NEW_PATH_DOCKER/"
sudo mv "$OLD_PATH_DOCKER/*" "$NEW_PATH_DOCKER/"

###     containerd (OLD_PATH_CONTAINERD)
sudo rsync -aHAX --info=progress2 "$OLD_PATH_CONTAINERD/" "$NEW_PATH_CONTAINERD/"
sudo mv "$OLD_PATH_CONTAINERD/*" "$NEW_PATH_CONTAINERD/"

###
### Configs:
### /etc/docker/daemon.json
###     "data-root": "$NEW_PATH_DOCKER"
### /etc/containerd/config.toml
###     root = "$NEW_PATH_CONTAINERD"
###
##################################################

##################################################
sudo systemctl start docker
