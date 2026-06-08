#!/bin/bash

borg_git() {
    git add .
    git commit -m 'dev'
    git push
}

borg_git_dev() {
    git add .
    git commit -m 'dev'
}

borg_git_amend() {
    git add .
    git commit --amend --no-edit
}

borg_git_pull_force() {
    git fetch origin && git reset --hard origin/$(git branch --show-current) && git clean -fd
}