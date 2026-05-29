#! /bin/bash

borg_dkr(){
    local TARGET=$1
    docker exec -it "$TARGET" bash || docker exec -it "$TARGET" sh
}