#!/bin/bash

SOURCE="/home/qqq/Downloads/"
DEST="/run/media/qqq/nix_tb/_A002/_downloads/"

# Validate source exists
if [ ! -d "$SOURCE" ]; then
    echo "Error: Source directory '$SOURCE' does not exist"
    exit 1
fi

# Check and attempt to create destination if it doesn't exist
if [ ! -d "$DEST" ]; then
    echo "Destination '$DEST' not found. Attempting to create..."
    mkdir -p "$DEST"
    if [ $? -ne 0 ]; then
        echo "Error: Could not create destination directory '$DEST'"
        exit 1
    else
        echo "Created destination: $DEST"
    fi
fi

# Final check
if [ ! -d "$DEST" ]; then
    echo "Error: Destination directory '$DEST' still does not exist after attempt to create"
    exit 1
fi

# Copy everything
echo "Copying files from '$SOURCE' to '$DEST'..."
rsync -av --progress "$SOURCE" "$DEST"

# Empty each first-level subfolder in SOURCE (keep the folder itself)
echo "Emptying first‑level subfolders in SOURCE..."
for folder in "$SOURCE"*/; do
    if [ -d "$folder" ]; then
        # Remove all files and subdirectories inside the folder
        find "$folder" -mindepth 1 -delete
        echo "Emptied: $folder"
    fi
done

echo "Complete: All first‑level folders in SOURCE are now empty"
