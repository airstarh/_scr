#! /bin/bash

borg_dkr(){
    local TARGET=$1
    docker exec -it "$TARGET" bash || docker exec -it "$TARGET" sh
}

borg_dkr_stop() {
    sudo systemctl stop docker.socker 2>/dev/null
    sudo systemctl stop docker 2>/dev/null
    sudo systemctl stop containerd 2>/dev/null
}

borg_dkr_start(){
    sudo systemctl start docker
}

borg_dkr_reboot(){
    # Stop and disable
    sudo systemctl stop docker.socker 2>/dev/null
    sudo systemctl stop docker 2>/dev/null
    sudo systemctl stop containerd 2>/dev/null

    sudo systemctl stop iptables 2>/dev/null
    sudo systemctl disable iptables 2>/dev/null

    # Also for netfilter-persistent
    sudo systemctl stop netfilter-persistent 2>/dev/null
    sudo systemctl disable netfilter-persistent 2>/dev/null

    # Flush all rules
    sudo iptables -F
    sudo iptables -X
    sudo iptables -t nat -F
    sudo iptables -t nat -X
    sudo iptables -t mangle -F
    sudo iptables -t mangle -X
    sudo iptables -P INPUT ACCEPT
    sudo iptables -P FORWARD ACCEPT
    sudo iptables -P OUTPUT ACCEPT

    # Make it persistent (so it stays after reboot)
    sudo apt remove -y iptables-persistent netfilter-persistent 2>/dev/null

    sudo systemctl start docker

    # verify
    sudo iptables -L -n
}

borg_dkr_mey_up(){
    cd /osa/_docker/mey
    docker compose up -d
}

borg_dkr_mey_down(){
    cd /osa/_docker/mey
    docker compose down
}

borg_dkr_create_network() {
    docker network create --driver bridge --ipv6=false bnet
}
