#! /bin/bash

borg_dkr(){
    local TARGET=$1
    docker exec -it "$TARGET" bash || docker exec -it "$TARGET" sh
}

borg_dkr_mey_up(){
    cd /osa/_docker/mey
    docker compose up -d
}

borg_dkr_mey_down(){
    cd /osa/_docker/mey
    docker compose down
}