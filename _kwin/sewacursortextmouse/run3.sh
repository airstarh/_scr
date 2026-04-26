#!/bin/bash
# enhanced_manual_tracker.sh

POSITION_FILE="$HOME/.config/text_cursor_positions.conf"

# Function to save position for current application
save_position() {
    # Get active window class (if possible)
    APP=$(kwin_active_window_class 2>/dev/null || echo "default")

    # Get current mouse position by moving to a known location first
    echo "Position saving in 2 seconds..."
    echo "Please move your mouse to the text area (where you type)"
    sleep 2

    # We can't read mouse position easily on Wayland, so ask user
    echo ""
    echo "Enter the coordinates where your text cursor usually appears:"
    read -p "X coordinate: " X
    read -p "Y coordinate: " Y

    if [[ -n "$X" && -n "$Y" ]]; then
        echo "$APP:$X:$Y" >> $POSITION_FILE
        echo "✓ Position saved for $APP: $X, $Y"
    else
        echo "✗ Invalid position"
    fi
}

# Function to move to saved position for current app
move_to_position() {
    APP=$(kwin_active_window_class 2>/dev/null || echo "default")

    # Look for app-specific position
    POS=$(grep "^$APP:" $POSITION_FILE 2>/dev/null | tail -1)

    if [ -z "$POS" ]; then
        # Fallback to default
        POS=$(grep "^default:" $POSITION_FILE 2>/dev/null | tail -1)
    fi

    if [ -n "$POS" ]; then
        X=$(echo "$POS" | cut -d':' -f2)
        Y=$(echo "$POS" | cut -d':' -f3)
        ydotool mousemove -x -9999 -y -9999 && ydotool mousemove -x $X -y $Y
        echo "✓ Moved to text area: $X, $Y"
    else
        echo "✗ No saved position. Run with --save first"
    fi
}

# Function to list saved positions
list_positions() {
    if [ -f $POSITION_FILE ]; then
        echo "=== Saved Positions ==="
        cat $POSITION_FILE
    else
        echo "No saved positions"
    fi
}

# Get active window class (limited Wayland info)
kwin_active_window_class() {
    # Try to get window info via KWin (limited on Wayland)
    qdbus org.kde.KWin /KWin getActiveWindow 2>/dev/null | head -1
}

# Main logic
case "$1" in
    --save)
        save_position
        ;;
    --list)
        list_positions
        ;;
    --listen)
        echo "=== Enhanced Manual Text Cursor Tracker ==="
        echo "Press Ctrl+Shift+I to move to saved text area"
        echo "Run with --save to set positions for different apps"
        echo ""

        dbus-monitor --session "type='signal'" 2>&1 | while read -r line; do
            if echo "$line" | grep -q "sewacursortextmouse"; then
                move_to_position
            fi
        done
        ;;
    *)
        echo "Usage: $0 [--listen|--save|--list]"
        echo "  --listen  : Listen for shortcut and move mouse (default mode)"
        echo "  --save    : Save current text area position"
        echo "  --list    : List all saved positions"
        ;;
esac