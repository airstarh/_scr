#!/bin/bash

borg_video() {
    ffmpeg \
        -y \
        -stats \
        -loglevel warning \
        -i "$1" \
        -vf "scale='min(1920,iw)':-2,fps=60" \
        -r 60 \
        -vcodec libx264 \
        -crf 20 \
        -preset superfast \
        -acodec aac \
        -b:a 128k \
        -movflags +faststart \
        "$2"
}


