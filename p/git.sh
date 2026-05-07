#!/bin/bash

borg_git() {
    git add .
    git commit -m 'dev'
    git push
}