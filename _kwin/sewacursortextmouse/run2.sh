python3 -c "
import dbus
bus = dbus.SessionBus()
atspi_bus = bus.get_object('org.a11y.Bus', '/org/a11y/bus')
atspi_iface = dbus.Interface(atspi_bus, 'org.a11y.Bus')
registry_address = atspi_iface.GetAddress()
print(f'Success! Registry address: {registry_address}')
"