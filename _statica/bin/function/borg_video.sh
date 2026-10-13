#!/bin/bash

borg_video() {
    ffmpeg \
        -stats \
        -loglevel warning \
        -i "$1" \
        -vcodec libx264 \
        -crf 22 \
        -preset medium \
        -acodec aac \
        -b:a 128k \
        -movflags +faststart \
        "$2"
}
