#! /bin/bash

NEW_PATH_DOCKER="/mnt/d1001/dockersys/docker"
NEW_PATH_CONTAINERD="/mnt/d1001/dockersys/containerd"

sudo systemctl stop docker.socket docker containerd

sudo mkdir -p "$NEW_PATH_DOCKER"
sudo mkdir -p "$NEW_PATH_CONTAINERD"

### Paths:
### dockersys
###     docker (/var/lib/docker)
sudo rsync -aHAX --info=progress2 /var/lib/docker/ "$NEW_PATH_DOCKER/"
sudo mv /var/lib/docker/* "$NEW_PATH_DOCKER/"

###     containerd (/var/lib/containerd)
sudo rsync -aHAX --info=progress2 /var/lib/containerd/ "$NEW_PATH_CONTAINERD/"
sudo mv /var/lib/containerd/* "$NEW_PATH_CONTAINERD/"

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
