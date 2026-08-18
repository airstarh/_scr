#!/bin/bash

borg_fs_A001(){
    rsync -rlvz --delete --no-perms --no-owner --no-group --progress /home/qqq/_A001/ qqq@192.168.1.120:/home/qqq/_A001/
}
