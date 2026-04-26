#!/bin/bash
# minimal_test.sh

echo "=== Minimal Test ==="
echo "This will move mouse to a fixed position (500,500) when you press Ctrl+Shift+I"

dbus-monitor --session "type='signal'" 2>&1 | while read -r line; do
    if echo "$line" | grep -q "sewacursortextmouse"; then
        echo ""
        echo "Shortcut detected! Moving mouse to test position..."

        # Test with a fixed position first
        ydotool mousemove -x -9999 -y -9999 && ydotool mousemove -x 100 -y 20

        if [ $? -eq 0 ]; then
            echo "✓ Mouse moved to 500,500"
        else
            echo "✗ ydotool failed - check if installed and user in input group"
        fi
    fi
done