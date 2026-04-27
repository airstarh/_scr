#!/bin/bash

SOURCE="/home/qqq/Downloads/"
DEST="/media/qqq/nix_tb/_A002/_downloads/"

# Copy everything
rsync -av --progress "$SOURCE" "$DEST"

# Empty each first-level subfolder (keep the folder itself)
for folder in "$SOURCE"*/; do
    if [ -d "$folder" ]; then
        echo "Emptying: $folder"
        rm -rf "$folder"*
    fi
done

echo "Complete: All first-level folders in SOURCE are now empty"