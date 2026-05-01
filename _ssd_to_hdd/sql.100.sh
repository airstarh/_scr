#!/bin/bash
# SCRIPT 1: Backup ZoneMinder and MySQL before migration
# Run this FIRST

set -e  # Stop on error

echo "========================================="
echo "SCRIPT 1: BACKUP ZONEMINDER & MYSQL"
echo "========================================="

# Create backup directory with timestamp
BACKUP_DIR=~/zm_migration_backup_$(date +%Y%m%d_%H%M%S)
mkdir -p "$BACKUP_DIR"
echo "✓ Backup directory created: $BACKUP_DIR"

# Backup ZoneMinder configuration
echo "Backing up ZoneMinder config..."
sudo cp -r /etc/zm "$BACKUP_DIR/zm_config" 2>/dev/null || echo "  (No /etc/zm found)"
sudo cp /etc/zm/zm.conf "$BACKUP_DIR/" 2>/dev/null || echo "  (No zm.conf found)"

# Backup MySQL database
echo "Backing up MySQL ZoneMinder database..."
sudo mysqldump --single-transaction --quick --lock-tables=false zm > "$BACKUP_DIR/zm_database.sql" 2>/dev/null

if [ -s "$BACKUP_DIR/zm_database.sql" ]; then
    echo "✓ Database backup successful: $(ls -lh $BACKUP_DIR/zm_database.sql | awk '{print $5}')"
else
    echo "⚠ Warning: Database backup appears empty or failed"
fi

# Backup MySQL users
echo "Backing up MySQL users..."
sudo mysqldump mysql user > "$BACKUP_DIR/mysql_users.sql" 2>/dev/null || echo "  (User backup skipped - not critical)"

# List all ZoneMinder data directories for reference
echo ""
echo "ZoneMinder data directories detected:"
ls -la /var/lib/zoneminder/ 2>/dev/null && echo "  ✓ /var/lib/zoneminder exists" || echo "  ✗ /var/lib/zoneminder NOT found"
ls -la /var/cache/zoneminder/ 2>/dev/null && echo "  ✓ /var/cache/zoneminder exists" || echo "  ✗ /var/cache/zoneminder NOT found"
ls -la /var/lib/mysql/zm/ 2>/dev/null && echo "  ✓ MySQL ZoneMinder database exists" || echo "  ✗ MySQL ZoneMinder database NOT found"

echo ""
echo "========================================="
echo "BACKUP COMPLETE! Backup location:"
echo "$BACKUP_DIR"
echo ""
echo "Verify the backup size before continuing:"
du -sh "$BACKUP_DIR"
echo "========================================="