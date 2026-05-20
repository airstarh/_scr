#!/bin/bash
# SCRIPT 2: Migrate ZoneMinder and MySQL to /osa HDD
# Run this AFTER backup script

set -e  # Stop on error

echo "========================================="
echo "SCRIPT 2: MIGRATE ZONEMINDER TO /osa HDD"
echo "========================================="

# Check if /osa is mounted
if ! mountpoint -q /osa; then
    echo "❌ ERROR: /osa is not mounted!"
    echo "Please mount your HDD to /osa first."
    exit 1
fi
echo "✓ /osa is mounted"

# Stop all services
echo ""
echo "Stopping services..."
sudo systemctl stop zoneminder 2>/dev/null && echo "✓ zoneminder stopped" || echo "  (zoneminder not running)"
sudo systemctl stop mysql 2>/dev/null && echo "✓ mysql stopped" || echo "  (mysql not running)"
sudo systemctl stop mariadb 2>/dev/null && echo "✓ mariadb stopped" || echo "  (mariadb not running)"
sudo systemctl stop apache2 2>/dev/null && echo "✓ apache2 stopped" || echo "  (apache2 not running)"
sudo systemctl stop nginx 2>/dev/null && echo "✓ nginx stopped" || echo "  (nginx not running)"

sleep 2
echo "✓ All services stopped"

# Create directory structure on /osa
echo ""
echo "Creating directory structure on /osa..."
sudo mkdir -p /osa/var/lib/mysql
sudo mkdir -p /osa/var/lib/zoneminder
sudo mkdir -p /osa/var/cache/zoneminder
sudo mkdir -p /osa/var/log/zoneminder
echo "✓ Directories created"

# Copy MySQL data
echo ""
echo "Copying MySQL data to /osa (this may take a while)..."
sudo chown mysql:mysql /osa/var/lib/mysql
sudo chmod 700 /osa/var/lib/mysql

if [ -d /var/lib/mysql ]; then
    sudo rsync -avxP --progress /var/lib/mysql/ /osa/var/lib/mysql/
    sudo mv /var/lib/mysql /var/lib/mysql.original
    echo "✓ MySQL data copied and original moved to /var/lib/mysql.original"
else
    echo "⚠ Warning: /var/lib/mysql not found - MySQL not installed?"
fi

# Copy ZoneMinder data
echo ""
echo "Copying ZoneMinder data to /osa..."
if [ -d /var/lib/zoneminder ]; then
    sudo rsync -avxP --progress /var/lib/zoneminder/ /osa/var/lib/zoneminder/
    sudo mv /var/lib/zoneminder /var/lib/zoneminder.original
    echo "✓ /var/lib/zoneminder migrated"
fi

if [ -d /var/cache/zoneminder ]; then
    sudo rsync -avxP --progress /var/cache/zoneminder/ /osa/var/cache/zoneminder/
    sudo mv /var/cache/zoneminder /var/cache/zoneminder.original
    echo "✓ /var/cache/zoneminder migrated"
fi

# Create bind mounts
echo ""
echo "Creating bind mounts..."
sudo mount --bind /osa/var/lib/mysql /var/lib/mysql
echo "✓ MySQL bind mount created"

sudo mount --bind /osa/var/lib/zoneminder /var/lib/zoneminder
echo "✓ ZoneMinder bind mount created"

if [ -d /osa/var/cache/zoneminder ]; then
    sudo mount --bind /osa/var/cache/zoneminder /var/cache/zoneminder
    echo "✓ ZoneMinder cache bind mount created"
fi

# Configure AppArmor
echo ""
echo "Configuring AppArmor for MySQL..."
APPARMOR_FILE="/etc/apparmor.d/usr.sbin.mysqld"
if [ -f "$APPARMOR_FILE" ]; then
    # Check if rules already exist
    if ! grep -q "/osa/var/lib/mysql/" "$APPARMOR_FILE"; then
        sudo sed -i '/\/var\/lib\/mysql\/\*\* rwk,/a\  /osa/var/lib/mysql/ r,\n  /osa/var/lib/mysql/** rwk,' "$APPARMOR_FILE"
        echo "✓ AppArmor rules added"
    else
        echo "✓ AppArmor rules already present"
    fi
    sudo systemctl reload apparmor
    echo "✓ AppArmor reloaded"
else
    echo "⚠ AppArmor MySQL profile not found - skipping"
fi

# Fix permissions
echo ""
echo "Setting correct permissions..."
sudo chown -R www-data:www-data /osa/var/lib/zoneminder 2>/dev/null
sudo chown -R mysql:mysql /osa/var/lib/mysql
echo "✓ Permissions set"

# Save current fstab if not already backed up
if [ ! -f /etc/fstab.backup ]; then
    sudo cp /etc/fstab /etc/fstab.backup
    echo "✓ Original fstab backed up to /etc/fstab.backup"
fi

# Add bind mounts to fstab
echo ""
echo "Adding bind mounts to /etc/fstab..."
grep -q "/osa/var/lib/mysql /var/lib/mysql" /etc/fstab || echo '/osa/var/lib/mysql /var/lib/mysql none bind 0 0' | sudo tee -a /etc/fstab > /dev/null
grep -q "/osa/var/lib/zoneminder /var/lib/zoneminder" /etc/fstab || echo '/osa/var/lib/zoneminder /var/lib/zoneminder none bind 0 0' | sudo tee -a /etc/fstab > /dev/null
grep -q "/osa/var/cache/zoneminder /var/cache/zoneminder" /etc/fstab || echo '/osa/var/cache/zoneminder /var/cache/zoneminder none bind 0 0' | sudo tee -a /etc/fstab > /dev/null
echo "✓ fstab entries added"

echo ""
echo "========================================="
echo "MIGRATION COMPLETE!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Run script 3: 03-test-and-start.sh"
echo ""
echo "To restore if something went wrong:"
echo "  sudo umount /var/lib/mysql /var/lib/zoneminder"
echo "  sudo mv /var/lib/mysql.original /var/lib/mysql"
echo "  sudo mv /var/lib/zoneminder.original /var/lib/zoneminder"
echo "========================================="