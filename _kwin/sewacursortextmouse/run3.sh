#!/bin/bash

echo "Testing text cursor detection..."

POS=$(python3 << 'EOF'
import dbus
import sys

try:
    bus = dbus.SessionBus()

    # Connect to AT-SPI bus
    atspi_bus = bus.get_object('org.a11y.Bus', '/org/a11y/bus')
    atspi_iface = dbus.Interface(atspi_bus, 'org.a11y.Bus')
    registry_address = atspi_iface.GetAddress()

    # Connect to registry
    registry_bus = dbus.bus.BusConnection(registry_address)

    # Get the root accessible object (correct API)
    root = registry_bus.get_object('org.a11y.atspi.Registry', '/org/a11y/atspi/accessible/root')
    root_iface = dbus.Interface(root, 'org.a11y.atspi.Accessible')

    # Get the application list or desktop directly
    # Try different approaches
    try:
        # Method 1: Get child count and iterate
        child_count = root_iface.GetChildCount()

        for i in range(child_count):
            child = root_iface.GetChildAtIndex(i)
            child_iface = dbus.Interface(child, 'org.a11y.atspi.Accessible')
            role = child_iface.GetRole()
            # ATSPI_ROLE_DESKTOP_FRAME = 41 (usually)
            if role == 41:  # Desktop frame
                desktop = child
                break
        else:
            # If no desktop frame found, use root
            desktop = root
    except:
        desktop = root

    def find_focused(obj, depth=0):
        if depth > 15:
            return None
        try:
            obj_iface = dbus.Interface(obj, 'org.a11y.atspi.Accessible')

            # Check if focused
            state_set = obj_iface.GetStateSet()
            if state_set.Contains(0x80000):  # ATSPI_STATE_FOCUSED
                # Check if it has text interface
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
                child_count = obj_iface.GetChildCount()
                for i in range(min(child_count, 50)):
                    child = obj_iface.GetChildAtIndex(i)
                    result = find_focused(child, depth + 1)
                    if result:
                        return result
            except:
                pass
        except Exception as e:
            pass
        return None

    result = find_focused(desktop)
    if not result:
        print("no_position")

except Exception as e:
    print(f"error: {e}")
EOF
)

if [[ "$POS" =~ ^[0-9]+,[0-9]+$ ]]; then
    X=$(echo "$POS" | cut -d',' -f1)
    Y=$(echo "$POS" | cut -d',' -f2)
    echo "✓ Text cursor found at: $X, $Y"
    ydotool mousemove -x -9999 -y -9999 && ydotool mousemove -x $X -y $Y
    echo "✓ Mouse moved to text cursor"
else
    echo "✗ Failed: $POS"
    echo ""
    echo "Troubleshooting:"
    echo "1. Focus on a text field in any application (Kate, Firefox, etc.)"
    echo "2. Make sure accessibility is enabled:"
    echo "   System Settings → Accessibility → Enable Screen Reader"
    echo "3. Try running: accerciser (install with: sudo apt install accerciser)"
fi