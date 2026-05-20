#!/bin/bash
# SCRIPT 3: Test and start services after migration
# Run this AFTER migration script

set -e  # Stop on error

echo "========================================="
echo "SCRIPT 3: TEST & START SERVICES"
echo "========================================="

# Verify bind mounts are working
echo ""
echo "Verifying bind mounts..."
for mount in /var/lib/mysql /var/lib/zoneminder; do
    if mountpoint -q "$mount"; then
        echo "✓ $mount is mounted"
    else
        echo "❌ ERROR: $mount is NOT mounted!"
        echo "Run: sudo mount --bind /osa$mount $mount"
        exit 1
    fi
done

# Verify /osa has space
echo ""
echo "HDD space available:"
df -h /osa | tail -1

# Start MySQL
echo ""
echo "Starting MySQL..."
sudo systemctl start mysql || sudo systemctl start mariadb

sleep 2
if sudo systemctl is-active --quiet mysql || sudo systemctl is-active --quiet mariadb; then
    echo "✓ MySQL/MariaDB is running"
else
    echo "❌ MySQL failed to start. Checking logs..."
    sudo tail -20 /var/log/mysql/error.log 2>/dev/null || sudo tail -20 /var/log/mariadb/error.log 2>/dev/null
    echo ""
    echo "Recovery options:"
    echo "1. Check AppArmor: sudo journalctl -xe | grep -i apparmor"
    echo "2. Restore from backup: See script 2 recovery instructions"
    exit 1
fi

# Test MySQL ZoneMinder database
echo ""
echo "Testing ZoneMinder database..."
if sudo mysql -e "USE zm; SELECT COUNT(*) FROM Events LIMIT 1;" 2>/dev/null; then
    EVENT_COUNT=$(sudo mysql -e "USE zm; SELECT COUNT(*) FROM Events;" 2>/dev/null | tail -1)
    echo "✓ ZoneMinder database accessible. Events count: $EVENT_COUNT"
else
    echo "⚠ Warning: Could not access ZoneMinder database"
    echo "  Database may be empty or not initialized yet"
fi

# Start ZoneMinder
echo ""
echo "Starting ZoneMinder..."
sudo systemctl start zoneminder

sleep 3
if sudo systemctl is-active --quiet zoneminder; then
    echo "✓ ZoneMinder is running"
else
    echo "❌ ZoneMinder failed to start. Checking logs..."
    sudo tail -30 /var/log/zm/zm.log 2>/dev/null || echo "  No log file found"
    echo ""
    echo "Try: sudo systemctl status zoneminder"
    exit 1
fi

# Start web server
echo ""
echo "Starting web server..."
sudo systemctl start apache2 2>/dev/null || sudo systemctl start nginx 2>/dev/null || echo "  (No web server found or already running)"

# Final checks
echo ""
echo "========================================="
echo "FINAL VERIFICATION"
echo "========================================="

echo ""
echo "Service status:"
sudo systemctl is-active --quiet mysql && echo "  ✅ MySQL: ACTIVE" || echo "  ❌ MySQL: INACTIVE"
sudo systemctl is-active --quiet zoneminder && echo "  ✅ ZoneMinder: ACTIVE" || echo "  ❌ ZoneMinder: INACTIVE"

echo ""
echo "Disk usage on /osa:"
df -h /osa | tail -1

echo ""
echo "Bind mounts active:"
mount | grep "/osa" | grep "bind" || echo "  (No bind mounts found)"

echo ""
echo "========================================="
echo "MIGRATION SUCCESSFUL!"
echo ""
echo "Next steps:"
echo "1. Log into ZoneMinder web interface"
echo "2. Check that both cameras show live view"
echo "3. Trigger a test recording and verify playback"
echo ""
echo "If everything works after 24 hours, you can remove backups:"
echo "  sudo rm -rf /var/lib/mysql.original"
echo "  sudo rm -rf /var/lib/zoneminder.original"
echo "  rm -rf ~/zm_migration_backup_*"
echo "========================================="