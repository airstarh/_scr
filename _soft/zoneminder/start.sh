#!/bin/bash

# restore-zoneminder-native.sh
# Re-enables and starts native ZoneMinder installation

echo "=== Restoring Native ZoneMinder Installation ==="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# Check if Docker ZoneMinder is running and offer to stop it
if command -v docker &> /dev/null; then
    if docker ps --format '{{.Names}}' | grep -q "^zoneminder$"; then
        echo "⚠ Docker ZoneMinder container is running"
        read -p "Stop and remove Docker ZoneMinder container? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker stop zoneminder 2>/dev/null
            docker rm zoneminder 2>/dev/null
            echo "✓ Docker ZoneMinder stopped and removed"
        else
            echo "Docker ZoneMinder will remain running - may cause port conflicts"
        fi
    fi
fi

# Enable ZoneMinder service
echo "Enabling ZoneMinder service..."
systemctl enable zoneminder
if [ $? -eq 0 ]; then
    echo "✓ ZoneMinder enabled for autostart"
else
    echo "✗ Failed to enable ZoneMinder"
    exit 1
fi

# Start ZoneMinder
echo "Starting ZoneMinder service..."
systemctl start zoneminder
if [ $? -eq 0 ]; then
    echo "✓ ZoneMinder started"
else
    echo "✗ Failed to start ZoneMinder"
    exit 1
fi

# Wait a moment for service to initialize
sleep 3

# Verify ZoneMinder is running
if systemctl is-active --quiet zoneminder; then
    echo "✓ ZoneMinder is running"
else
    echo "✗ ZoneMinder failed to start"
    echo "Checking logs..."
    journalctl -u zoneminder -n 20 --no-pager
    exit 1
fi

# Check and start Apache if needed
echo "Checking web server status..."
if ! systemctl is-active --quiet apache2; then
    echo "Starting Apache web server..."
    systemctl start apache2
    systemctl enable apache2
    if [ $? -eq 0 ]; then
        echo "✓ Apache started and enabled"
    else
        echo "⚠ Failed to start Apache - web interface may not work"
    fi
else
    echo "✓ Apache is running"
fi

# Check MySQL/MariaDB
echo "Checking database server..."
if systemctl is-active --quiet mysql 2>/dev/null || systemctl is-active --quiet mariadb 2>/dev/null; then
    echo "✓ Database server is running"
else
    echo "⚠ Database server is not running - attempting to start..."
    systemctl start mysql 2>/dev/null || systemctl start mariadb 2>/dev/null
fi

# Display status
echo ""
echo "=== ZoneMinder Status ==="
systemctl status zoneminder --no-pager -l

echo ""
echo "=== Running Processes ==="
ps aux | grep -E 'zma|zmc|zmdc' | grep -v grep

echo ""
echo "=== ZoneMinder Successfully Restored ==="
echo "Web interface should be available at:"
echo "  → http://localhost/zm"
echo "  → http://localhost/zoneminder"
echo ""
echo "To check logs if needed:"
echo "  sudo tail -f /var/log/zm/zmdc.log"