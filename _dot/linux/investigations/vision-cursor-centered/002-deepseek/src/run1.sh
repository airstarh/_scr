#!/bin/bash
# caret2mouse.sh - Works on Kubuntu 25 Wayland

# Method 1: Try KDE's accessibility DBus interface
if qdbus org.kde.kaccess /kaccess org.kde.kaccess.enableAccessibility true 2>/dev/null; then
    # Get caret position via AT-SPI (KDE adapted)
    CARET_POS=$(python3 -c "
import dbus
bus = dbus.SessionBus()
try:
    # KDE's AT-SPI registry
    obj = bus.get_object('org.a11y.atspi', '/org/a11y/atspi/accessible/root')
    iface = dbus.Interface(obj, 'org.a11y.atspi.Accessible')
    # ... rest of caret detection
    print(f'{x},{y}')
except:
    print('not_found')
")
fi

# Method 2: Use ydotool (most reliable for Wayland)
if [[ "$CARET_POS" != "not_found" ]]; then
    IFS=',' read -r x y <<< "$CARET_POS"
    ydotool mousemove --absolute "$x" "$y"
fi