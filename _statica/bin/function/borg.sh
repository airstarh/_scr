#!/bin/bash

borg() {
    source ~/.bashrc
}

borg_log() {
    bash ~/000 > ~/ln-log 2>&1
}

borg_zm_up() {
    cd /osa/_docker/vzm || exit
    docker compose up -d
}

borg_zm_down() {
    cd /osa/_docker/vzm || exit
    docker compose down
}