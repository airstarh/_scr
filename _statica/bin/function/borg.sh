#!/bin/bash

borg() {
    . ~/.bashrc
}

borg_log() {
    sudo bash /home/qqq/000 > /home/qqq/ln-log 2>&1
}

borg_zm_up() {
    cd /osa/_docker/vzm || exit
    docker compose up -d
}

borg_zm_down() {
    cd /osa/_docker/vzm || exit
    docker compose down
}

borg_spent() {
    local start_time=$1
    local end_time=$2

    # Math with decimals in Bash requires 'bc' or stripping the dot.
    # To prevent overflows, we convert the float into pure milliseconds cleanly:
    local start_ms=$(echo "$start_time" | awk '{printf "%d", $1*1000}')
    local end_ms=$(echo "$end_time" | awk '{printf "%d", $1*1000}')

    # Calculate total elapsed milliseconds safely
    local elapsed=$((end_ms - start_ms))

    # Convert milliseconds to standard units
    local total_seconds=$((elapsed / 1000))
    local ms=$((elapsed % 1000))

    local hours=$((total_seconds / 3600))
    local minutes=$(((total_seconds % 3600) / 60))
    local seconds=$((total_seconds % 60))

    # Print the formatted result perfectly
    echo "SPENT: $(printf "%02d:%02d:%02d.%03d" $hours $minutes $seconds $ms)"
}


