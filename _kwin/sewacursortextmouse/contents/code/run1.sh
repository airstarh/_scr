#!/bin/bash
# This script gets the REAL text cursor position via AT-SPI

# Function to get actual text cursor position
get_caret_position() {
    python3 << 'EOF'
import dbus
import sys

try:
    bus = dbus.SessionBus()
    reg = bus.get_object('org.a11y.atspi', '/org/a11y/atspi/accessible/root')
    iface = dbus.Interface(reg, 'org.a11y.atspi.Accessible')

    # Get active window and focused component
    desktop = iface.GetDesktop(0)

    # Simplified: find focused text component
    def find_focused(obj, depth=0):
        if depth > 10:
            return None
        try:
            state_set = obj.GetStateSet()
            if state_set.Contains(0x80000):  # Focused
                # Check if it has text
                try:
                    text_iface = dbus.Interface(obj, 'org.a11y.atspi.Text')
                    caret = text_iface.GetCaretOffset()
                    rect = text_iface.GetCharacterExtents(caret, 0)
                    x = rect[0] + rect[2]//2
                    y = rect[1] + rect[3]//2
                    print(f"{x},{y}")
                    return obj
                except:
                    pass

            # Check children
            for i in range(obj.GetChildCount()):
                result = find_focused(obj.GetChildAtIndex(i), depth+1)
                if result:
                    return result
        except:
            pass
        return None

    find_focused(desktop)
except Exception as e:
    sys.stderr.write(f"Error: {e}\n")
    print("no_position")
EOF
}

# Listen for DBus signal from KWin script
dbus-monitor --session "type='signal',interface='local.CursorTracker',member='MoveRequest'" 2>/dev/null |
while read -r line; do
    if [[ $line == *"MoveRequest"* ]]; then
        echo "Signal received, getting text cursor position..."

        # Get actual text cursor position
        POS=$(get_caret_position)

        if [[ $POS != "no_position" ]] && [[ $POS =~ ^[0-9]+,[0-9]+$ ]]; then
            X=$(echo $POS | cut -d',' -f1)
            Y=$(echo $POS | cut -d',' -f2)

            # Move mouse (requires ydotool)
            ### ydotool mousemove --absolute $X $Y
            ydotool mousemove -x -9999 -y -9999 && ydotool mousemove -x $X -y $y
            echo "Moved mouse to text cursor at: $X, $Y"
        else
            echo "Could not find text cursor position"
        fi
    fi
done