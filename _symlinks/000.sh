# Check if NetworkManager is even running
systemctl status NetworkManager

# See your active connections (what's connected RIGHT NOW)
nmcli connection show

# See all devices and their current state
nmcli device status

# See if NetworkManager is managing your interfaces
nmcli device show