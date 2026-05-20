#!/bin/bash

### USAGE
# cd ~/_A001/_TRASH$
# bash ~/_A001/_scr/_ssh/sameContent.sh
###

# Debug: Show where we are
echo "Current directory: $(pwd)"
echo "Files in directory:"
ls -la

# Temporary file to store checksums and filenames
temp_file=$(mktemp)
echo "Using temp file: $temp_file"

# Generate MD5 checksums for all files and save to temp file
echo "Running md5sum on files..."
find . -maxdepth 1 -type f -exec md5sum {} \; 2>/dev/null | sort > "$temp_file"

# Show what's in the temp file (debug)
echo "Temp file contents:"
cat "$temp_file"
echo "---"

# Find and display duplicate files
echo "Files with identical content:"
echo "=========================="

awk '{
    checksum = $1
    # Remove checksum and any whitespace to get the filename
    sub(/^[^ ]+[[:space:]]+/, "")
    filename = $0

    # Group files by checksum
    if (checksum in files) {
        files[checksum] = files[checksum] "\n\t" filename
    } else {
        files[checksum] = filename
    }
    counts[checksum]++
}

END {
    found=0
    for (c in files) {
        if (counts[c] > 1) {
            print "Checksum " c ":"
            print "\t" files[c]
            print ""
            found=1
        }
    }
    if (found == 0) {
        print "No duplicate files found."
    }
}' "$temp_file"

# Clean up
rm -f "$temp_file"
