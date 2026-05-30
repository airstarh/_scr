#! /bin/bash

borg_bt(){
    sudo systemctl restart bluetooth && sudo systemctl restart input-remapper-daemon && pkill solaar && solaar --window=hide &
}
