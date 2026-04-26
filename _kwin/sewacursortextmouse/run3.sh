#!/bin/bash
# practical_solution_fixed.sh

echo "=== Practical Text Cursor Follower (Fixed) ==="
echo "Moves mouse to center of active window"
echo "Press Ctrl+Shift+I to activate"

get_window_center() {
    python3 << 'EOF'
import dbus
import sys

try:
    bus = dbus.SessionBus()

    # Method 1: Try to get active window via KWin
    try:
        kwin = bus.get_object('org.kde.KWin', '/KWin')
        kwin_iface = dbus.Interface(kwin, 'org.kde.KWin')

        # Get active window as integer
        active_window_int = kwin_iface.activeWindow()

        # Convert to string for getWindowInfo
        active_window = str(active_window_int)

        # Get window geometry
        geometry = kwin_iface.getWindowInfo(active_window)

        # Parse geometry - format varies, try different patterns
        import re

        # Pattern 1: "x,y width,height"
        match = re.search(r'(\d+),(\d+)\s+(\d+),(\d+)', geometry)
        if match:
            x = int(match.group(1))
            y = int(match.group(2))
            width = int(match.group(3))
            height = int(match.group(4))
        else:
            # Pattern 2: "x y width height"
            match = re.search(r'(\d+)\s+(\d+)\s+(\d+)\s+(\d+)', geometry)
            if match:
                x = int(match.group(1))
                y = int(match.group(2))
                width = int(match.group(3))
                height = int(match.group(4))
            else:
                print("no_position")
                return

        # Return center of window
        center_x = x + width // 2
        center_y = y + height // 2
        print(f"{center_x},{center_y}")

    except Exception as e:
        print(f"error: {e}")

except Exception as e:
    print(f"error: {e}")
EOF
}

# Listen for shortcut
dbus-monitor --session "type='signal'" 2>&1 | while read -r line; do
    if echo "$line" | grep -q "sewacursortextmouse"; then
        echo ""
        echo "$(date '+%H:%M:%S'): Shortcut detected!"

        POS=$(get_window_center)

        if [[ "$POS" =~ ^[0-9]+,[0-9]+$ ]]; then
            X=$(echo "$POS" | cut -d',' -f1)
            Y=$(echo "$POS" | cut -d',' -f2)

            echo "Moving mouse to window center: $X, $Y"
            ydotool mousemove -x -9999 -y -9999 && ydotool mousemove -x $X -y $Y

            if [ $? -eq 0 ]; then
                echo "✓ Mouse moved successfully"
            else
                echo "✗ ydotool failed"
            fi
        else
            echo "✗ Could not get window position: $POS"
        fi
        echo "---"
    fi
done