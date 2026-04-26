#!/bin/bash
# test_cursor.sh

echo "Testing text cursor detection..."
echo "Please click inside a text field (Kate, terminal, etc.)"

sleep 2

python3 << 'EOF'
import dbus
import sys

def find_text_cursor(obj, depth=0):
    if depth > 10:
        return None

    try:
        obj_iface = dbus.Interface(obj, 'org.a11y.atspi.Accessible')

        # Check for text cursor
        try:
            text_iface = dbus.Interface(obj, 'org.a11y.atspi.Text')
            caret = text_iface.GetCaretOffset()
            if caret >= 0:
                rect = text_iface.GetCharacterExtents(caret, 0)
                if rect and len(rect) >= 4:
                    x = rect[0] + (rect[2] // 2)
                    y = rect[1] + (rect[3] // 2)
                    if x > 0 and y > 0:
                        print(f"Cursor found at: X={x}, Y={y}")
                        print(f"Caret position: {caret}")
                        print(f"Rectangle: {rect}")
                        return (x, y)
        except:
            pass

        # Search children
        try:
            child_count = obj_iface.GetChildCount()
            for i in range(child_count):
                child = obj_iface.GetChildAtIndex(i)
                result = find_text_cursor(child, depth + 1)
                if result:
                    return result
        except:
            pass

        return None
    except:
        return None

try:
    # Connect to AT-SPI
    bus = dbus.SessionBus()
    atspi_bus = bus.get_object('org.a11y.Bus', '/org/a11y/bus')
    atspi_iface = dbus.Interface(atspi_bus, 'org.a11y.Bus')
    registry_address = atspi_iface.GetAddress()

    registry_bus = dbus.bus.BusConnection(registry_address)
    root = registry_bus.get_object('org.a11y.atspi.Registry', '/org/a11y/atspi/accessible/root')

    print("Searching for text cursor...")
    result = find_text_cursor(root)

    if not result:
        print("No text cursor found")
        print("Make sure:")
        print("1. You clicked inside a text field")
        print("2. Accessibility is enabled")

except Exception as e:
    print(f"Error: {e}")
EOF