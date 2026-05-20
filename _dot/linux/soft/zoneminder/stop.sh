#!/bin/bash

# stop-zoneminder-for-docker.sh
# Stops native ZoneMinder service for Docker migration

echo "=== Stopping Native ZoneMinder for Docker Migration ==="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# Stop ZoneMinder service
echo "Stopping ZoneMinder service..."
systemctl stop zoneminder
if [ $? -eq 0 ]; then
    echo "✓ ZoneMinder stopped successfully"
else
    echo "✗ Failed to stop ZoneMinder"
    exit 1
fi

# Disable ZoneMinder from starting on boot
echo "Disabling ZoneMinder autostart..."
systemctl disable zoneminder
if [ $? -eq 0 ]; then
    echo "✓ ZoneMinder disabled"
else
    echo "✗ Failed to disable ZoneMinder"
fi

# Check if Apache is running and optionally stop it
echo "Checking Apache status..."
if systemctl is-active --quiet apache2; then
    echo "⚠ Apache is running (may conflict with Docker ports)"
    read -p "Stop Apache as well? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        systemctl stop apache2
        systemctl disable apache2
        echo "✓ Apache stopped and disabled"
    else
        echo "Apache will continue running - ensure Docker uses different ports"
    fi
else
    echo "✓ Apache is not running"
fi

# Verify ZoneMinder is stopped
echo "Verifying ZoneMinder status..."
sleep 2
if systemctl is-active --quiet zoneminder; then
    echo "✗ ZoneMinder is still running!"
    exit 1
else
    echo "✓ ZoneMinder is stopped and disabled"
fi

# Check for running ZoneMinder processes
ZMPROCS=$(ps aux | grep -E 'zma|zmc|zmdc' | grep -v grep | wc -l)
if [ $ZMPROCS -eq 0 ]; then
    echo "✓ No ZoneMinder processes running"
else
    echo "⚠ Found $ZMPROCS ZoneMinder processes - cleaning up..."
    pkill -f 'zma|zmc|zmdc'
fi

echo ""
echo "=== Native ZoneMinder is ready for Docker ==="
echo "You can now run your Docker ZoneMinder container"