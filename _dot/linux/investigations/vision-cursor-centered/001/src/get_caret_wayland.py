#!/usr/bin/env python3
import dbus
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib

DBusGMainLoop(set_as_default=True)
bus = dbus.SessionBus()

def get_caret_position():
    try:
        # Get root accessible object
        root = bus.get_object('org.a11y.atspi.Registry', '/org/a11y/atspi/accessible/root')
        registry_iface = dbus.Interface(root, 'org.a11y.atspi.Accessible')

        # Navigate to focused component
        app = registry_iface.GetApplication()
        desktop = app.GetDesktop(0)
        active_window = desktop.GetActiveWindow()
        focused = active_window.GetFocusedComponent()

        # Check if it's a text component
        text_iface = dbus.Interface(focused, 'org.a11y.atspi.Text')
        caret_offset = text_iface.GetCaretOffset()
        rect = text_iface.GetCharacterExtents(caret_offset, 0)  # (x, y, width, height)

        # Return center of caret rectangle
        x_center = rect[0] + rect[2] // 2
        y_center = rect[1] + rect[3] // 2
        return x_center, y_center
    except Exception as e:
        print(f"Error detecting caret: {e}")
        return None

pos = get_caret_position()
if pos:
    print(f"{pos[0]},{pos[1]}")
else:
    print("caret,not_found")
