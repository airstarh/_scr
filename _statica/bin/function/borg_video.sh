#!/bin/bash

borg_video() {
    ffmpeg \
        -y \
        -stats \
        -loglevel warning \
        -i "$1" \
        -vf "scale='min(1280,iw)':-2" \
        -r 30 \
        -vcodec libx264 \
        -crf 23 \
        -preset veryfast \
        -acodec aac \
        -b:a 64k \
        -movflags +faststart \
        "$2"
}
