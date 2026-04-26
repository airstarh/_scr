#!/bin/bash

echo "=== SEWA Mouse Cursor Tracker Started ==="
echo "Monitoring for cursor movement requests..."

# Function to get text cursor position via AT-SPI
get_caret_position() {
    python3 << 'EOF'
import dbus
import sys

try:
    # Connect to session bus
    bus = dbus.SessionBus()

    # Connect to AT-SPI (works with your system)
    atspi_bus = bus.get_object('org.a11y.Bus', '/org/a11y/bus')
    atspi_iface = dbus.Interface(atspi_bus, 'org.a11y.Bus')
    registry_address = atspi_iface.GetAddress()

    # Connect to registry
    registry_bus = dbus.bus.BusConnection(registry_address)
    reg = registry_bus.get_object('org.a11y.atspi.Registry', '/org/a11y/atspi/accessible/root')
    iface = dbus.Interface(reg, 'org.a11y.atspi.Accessible')

    # Get desktop
    desktop = iface.GetDesktop(0)

    def find_focused(obj, depth=0):
        if depth > 15:
            return None
        try:
            # Check if focused
            state_set = obj.GetStateSet()
            if state_set.Contains(0x80000):  # ATSPI_STATE_FOCUSED
                # Check if text interface exists
                try:
                    text_iface = dbus.Interface(obj, 'org.a11y.atspi.Text')
                    caret = text_iface.GetCaretOffset()
                    if caret >= 0:
                        rect = text_iface.GetCharacterExtents(caret, 0)
                        x = rect[0] + (rect[2] // 2)
                        y = rect[1] + (rect[3] // 2)
                        print(f"{x},{y}")
                        return obj
                except:
                    pass

            # Check children
            try:
                child_count = obj.GetChildCount()
                for i in range(min(child_count, 50)):
                    child = obj.GetChildAtIndex(i)
                    result = find_focused(child, depth + 1)
                    if result:
                        return result
            except:
                pass
        except:
            pass
        return None

    result = find_focused(desktop)
    if not result:
        print("no_position")

except Exception as e:
    print(f"error: {e}")
EOF
}

# Test if AT-SPI works on startup
echo "Testing AT-SPI connection..."
TEST_POS=$(get_caret_position)
echo "Test result: $TEST_POS"

# Listen for ANY DBus activity (simpler approach)
echo ""
echo "Now listening for DBus signals..."
echo "Press Ctrl+Shift+I in any application"
echo ""

dbus-monitor --session 2>&1 | while read -r line; do
    # Look for ANY mention of our shortcut or cursor
    if echo "$line" | grep -i -E "sewacursortextmouse|cursor|move|Ctrl\+Shift\+I" > /dev/null; then
        echo ""
        echo ">>> DBus activity detected at $(date '+%H:%M:%S') <<<"
        echo "Raw: $line"
        echo ""

        # Try to get cursor position
        POS=$(get_caret_position)

        if [[ "$POS" =~ ^[0-9]+,[0-9]+$ ]]; then
            X=$(echo "$POS" | cut -d',' -f1)
            Y=$(echo "$POS" | cut -d',' -f2)

            echo "✓ Text cursor found at: $X, $Y"

            # Move mouse with ydotool
            ydotool mousemove -x -9999 -y -9999 && ydotool mousemove -x $X -y $Y
            echo "✓ Mouse moved to text cursor"
        else
            echo "✗ Could not get text cursor position"
            echo "  Result: $POS"
        fi
        echo "----------------------------------------"
    fi
done