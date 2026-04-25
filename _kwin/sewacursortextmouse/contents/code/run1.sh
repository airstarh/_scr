#!/bin/bash
# mouse_mover.sh

# Listen for DBus signals from KWin
dbus-monitor --session "type='signal',interface='local.MoveCursor',member='move'" |
while read -r line; do
    # Extract coordinates (Simplified parsing - adjust based on actual signal output)
    if [[ $line =~ ([0-9.]+),([0-9.]+) ]]; then
        X=${BASH_REMATCH[1]}
        Y=${BASH_REMATCH[2]}

        # Use ydotool to move mouse (Low-level Wayland input)
        # Note: Requires ydotool installed and user in 'input' group
        ### INIT BUT BUG:ydotool mousemove --absolute $X $Y
        ydotool mousemove -x -99999 -y -99999 && ydotool mousemove $X $Y
        echo "Moved mouse to $X, $Y"
    fi
done