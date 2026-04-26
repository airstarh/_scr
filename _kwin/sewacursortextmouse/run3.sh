#!/bin/bash
# debug_atspi.sh - Explore the accessibility tree

python3 << 'EOF'
import dbus
import sys

def print_tree(obj, prefix="", depth=0):
    if depth > 5:
        return

    try:
        obj_iface = dbus.Interface(obj, 'org.a11y.atspi.Accessible')

        # Get basic info
        name = ""
        role = ""
        try:
            name = obj_iface.GetName()
        except:
            name = "unknown"

        try:
            role = str(obj_iface.GetRole())
        except:
            role = "unknown"

        # Check if focused
        is_focused = False
        try:
            state_set = obj_iface.GetStateSet()
            is_focused = state_set.Contains(0x80000)
        except:
            pass

        # Check if has text
        has_text = False
        try:
            text_iface = dbus.Interface(obj, 'org.a11y.atspi.Text')
            has_text = True
        except:
            pass

        focus_mark = " [FOCUSED]" if is_focused else ""
        text_mark = " [TEXT]" if has_text else ""

        print(f"{prefix}Role: {role}, Name: {name}{focus_mark}{text_mark}")

        # Get children
        try:
            child_count = obj_iface.GetChildCount()
            for i in range(min(child_count, 10)):  # Limit to 10 children
                child = obj_iface.GetChildAtIndex(i)
                print_tree(child, prefix + "  ", depth + 1)
        except:
            pass
    except Exception as e:
        print(f"{prefix}Error: {e}")

try:
    print("=== AT-SPI Accessibility Tree Debug ===")
    print("")

    bus = dbus.SessionBus()

    # Connect to AT-SPI
    atspi_bus = bus.get_object('org.a11y.Bus', '/org/a11y/bus')
    atspi_iface = dbus.Interface(atspi_bus, 'org.a11y.Bus')
    registry_address = atspi_iface.GetAddress()

    registry_bus = dbus.bus.BusConnection(registry_address)
    root = registry_bus.get_object('org.a11y.atspi.Registry', '/org/a11y/atspi/accessible/root')

    print("Root accessible object obtained")
    print("")
    print_tree(root)

except Exception as e:
    print(f"Error: {e}")
EOF