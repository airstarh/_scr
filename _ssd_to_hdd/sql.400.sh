#!/bin/bash

#Quick Recovery Script (If Needed)
# Emergency recovery - run if something breaks

echo "EMERGENCY RECOVERY - Reverting all changes"

# Stop services
sudo systemctl stop zoneminder mysql 2>/dev/null

# Unmount bind mounts
sudo umount /var/lib/mysql 2>/dev/null
sudo umount /var/lib/zoneminder 2>/dev/null
sudo umount /var/cache/zoneminder 2>/dev/null

# Restore originals
sudo rm -rf /var/lib/mysql 2>/dev/null
sudo rm -rf /var/lib/zoneminder 2>/dev/null
sudo rm -rf /var/cache/zoneminder 2>/dev/null

sudo mv /var/lib/mysql.original /var/lib/mysql 2>/dev/null
sudo mv /var/lib/zoneminder.original /var/lib/zoneminder 2>/dev/null
sudo mv /var/cache/zoneminder.original /var/cache/zoneminder 2>/dev/null

# Restart services
sudo systemctl start mysql
sudo systemctl start zoneminder

echo "Recovery complete. Check with: sudo systemctl status zoneminder"