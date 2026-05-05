#!/bin/bash

# Find the Polyvision CMS folder
CMS_PATH="$HOME/.wine/drive_c/Program Files (x86)/Polyvision/CMS"

# Check if folder exists
if [ ! -d "$CMS_PATH" ]; then
    echo "ERROR: CMS folder not found at $CMS_PATH"
    echo "Searching for Polyvision folder instead..."
    CMS_PATH=$(find "$HOME/.wine/drive_c" -type d -name "Polyvision" 2>/dev/null | head -1)
    if [ -z "$CMS_PATH" ]; then
        echo "ERROR: Could not find Polyvision folder"
        exit 1
    fi
    echo "Found at: $CMS_PATH"
fi

# Create output file on your desktop
OUTPUT_FILE="$HOME/Desktop/polyvision_config_analysis.txt"

echo "=========================================" > "$OUTPUT_FILE"
echo "Polyvision CMS Configuration Files Analysis" >> "$OUTPUT_FILE"
echo "Generated: $(date)" >> "$OUTPUT_FILE"
echo "=========================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Find all configuration files
echo "Searching for configuration files..." | tee -a "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

find "$CMS_PATH" -type f \( -name "*.ini" -o -name "*.conf" -o -name "*.cfg" -o -name "*.xml" -o -name "*.json" \) 2>/dev/null | while read -r FILE; do
    echo "----------------------------------------" >> "$OUTPUT_FILE"
    echo "FILE: $FILE" >> "$OUTPUT_FILE"
    echo "----------------------------------------" >> "$OUTPUT_FILE"

    # Get file size
    SIZE=$(wc -c < "$FILE" 2>/dev/null | tr -d ' ')

    # Only show files smaller than 100KB to avoid huge logs
    if [ "$SIZE" -lt 100000 ]; then
        echo "CONTENTS:" >> "$OUTPUT_FILE"
        cat "$FILE" 2>/dev/null >> "$OUTPUT_FILE"
    else
        echo "CONTENTS: File too large ($SIZE bytes), showing first 50 lines only" >> "$OUTPUT_FILE"
        head -50 "$FILE" 2>/dev/null >> "$OUTPUT_FILE"
    fi
    echo "" >> "$OUTPUT_FILE"
done

echo "=========================================" >> "$OUTPUT_FILE"
echo "Analysis complete" >> "$OUTPUT_FILE"
echo "Output saved to: $OUTPUT_FILE"

# Also look for hardware/GPU related settings specifically
echo "" >> "$OUTPUT_FILE"
echo "=========================================" >> "$OUTPUT_FILE"
echo "SEARCHING FOR HARDWARE-RELATED SETTINGS:" >> "$OUTPUT_FILE"
echo "=========================================" >> "$OUTPUT_FILE"

grep -r -i -n "hardware\|gpu\|dxva\|hwaccel\|decode\|render\|display\|opengl\|directx\|d3d" "$CMS_PATH" 2>/dev/null >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "Done! File saved to: $OUTPUT_FILE"