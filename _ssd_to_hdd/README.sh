Excellent idea! Here's a **complete, reusable toolkit** for migrating a fresh Kubuntu install to use a 1TB HDD for all large data.

## File Structure
```
~/migration-toolkit/
├── 00-config.sh           # Configuration file (edit this once)
├── 01-prepare-hdd.sh      # Format and mount HDD
├── 02-migrate-home-srv.sh # Move /home and /srv
├── 03-migrate-docker.sh   # Move Docker
├── 04-migrate-mysql-zm.sh # Move MySQL & ZoneMinder
├── 05-migrate-opt.sh      # Move /opt (optional)
└── 06-verify.sh           # Verify everything works
```

## Script 1: `00-config.sh` (Configuration - Edit This)

```bash
#!/bin/bash
# ============================================
# CONFIGURATION FILE - Edit these variables
# ============================================

# HDD device (find with: lsblk)
# Example: /dev/sda or /dev/sdb
HDD_DEV="/dev/sda"

# HDD partition number (usually 1)
HDD_PART="1"

# HDD mount point (where all data will live)
HDD_MOUNT="/osa"

# ZoneMinder database name (usually "zm")
ZM_DATABASE="zm"

# Use Docker? (yes/no)
USE_DOCKER="yes"

# Use ZoneMinder? (yes/no)
USE_ZONEMINDER="yes"

# Filesystem type (ext4 is recommended)
FILESYSTEM="ext4"

# ============================================
# DO NOT EDIT BELOW THIS LINE
# ============================================
HDD_FULL="${HDD_DEV}${HDD_PART}"
```

## Script 2: `01-prepare-hdd.sh` - Prepare HDD

```bash
#!/bin/bash
# ============================================
# SCRIPT 1: Prepare HDD - Format and Mount
# Usage: sudo ./01-prepare-hdd.sh
# ============================================

set -e  # Stop on error

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-config.sh"

echo "========================================="
echo "STEP 1: Prepare HDD for Migration"
echo "========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run as root: sudo $0"
    exit 1
fi

# Show current disks
echo ""
echo "Current disks:"
lsblk -o NAME,SIZE,MODEL,MOUNTPOINT

echo ""
echo "⚠️  WARNING: This will format ${HDD_FULL}"
echo "All data on this drive will be LOST!"
read -p "Type 'YES' to continue: " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
    echo "Aborted."
    exit 1
fi

# Format HDD if not already ext4
if [ "$(blkid -s TYPE -o value ${HDD_FULL})" != "$FILESYSTEM" ]; then
    echo "Formatting ${HDD_FULL} as ${FILESYSTEM}..."
    sudo mkfs.${FILESYSTEM} ${HDD_FULL}
fi

# Get UUID
UUID=$(blkid -s UUID -o value ${HDD_FULL})
echo "HDD UUID: $UUID"

# Create mount point
mkdir -p $HDD_MOUNT

# Add to fstab
if ! grep -q "$HDD_MOUNT" /etc/fstab; then
    echo "UUID=$UUID $HDD_MOUNT $FILESYSTEM defaults,nofail 0 2" >> /etc/fstab
    echo "✅ Added to /etc/fstab"
fi

# Mount
mount -a
echo "✅ HDD mounted at $HDD_MOUNT"

# Create directory structure
mkdir -p $HDD_MOUNT/{home,srv,opt,usr/local}
mkdir -p $HDD_MOUNT/var/lib/{mysql,docker}
mkdir -p $HDD_MOUNT/var/{cache/zoneminder,log}
mkdir -p $HDD_MOUNT/etc

echo "✅ Directory structure created"

# Save UUID for other scripts
echo "HDD_UUID=\"$UUID\"" > "$SCRIPT_DIR/.hdd_uuid"

echo ""
echo "========================================="
echo "✅ HDD PREPARATION COMPLETE"
echo "========================================="
df -h $HDD_MOUNT
```

## Script 3: `02-migrate-home-srv.sh` - Move Home and Srv

```bash
#!/bin/bash
# ============================================
# SCRIPT 2: Migrate /home and /srv to HDD
# Usage: sudo ./02-migrate-home-srv.sh
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-config.sh"

echo "========================================="
echo "STEP 2: Migrate /home and /srv"
echo "========================================="

if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run as root: sudo $0"
    exit 1
fi

# Verify HDD is mounted
if ! mountpoint -q $HDD_MOUNT; then
    echo "❌ $HDD_MOUNT is not mounted"
    exit 1
fi

# Stop services that might use /home
systemctl stop docker 2>/dev/null
systemctl stop zoneminder 2>/dev/null

# Migrate /home
echo ""
echo "Migrating /home..."
if [ -d "/home" ] && [ ! -L "/home" ]; then
    rsync -avxP --progress /home/ $HDD_MOUNT/home/
    mv /home /home.old
    ln -s $HDD_MOUNT/home /home
    echo "✅ /home migrated"
else
    echo "⚠️  /home already a symlink or not found"
fi

# Migrate /srv
echo ""
echo "Migrating /srv..."
if [ -d "/srv" ] && [ ! -L "/srv" ]; then
    rsync -avxP --progress /srv/ $HDD_MOUNT/srv/
    mv /srv /srv.old
    ln -s $HDD_MOUNT/srv /srv
    echo "✅ /srv migrated"
else
    echo "⚠️  /srv already a symlink or not found"
fi

echo ""
echo "========================================="
echo "✅ HOME AND SRV MIGRATION COMPLETE"
echo "========================================="
echo "IMPORTANT: Log out and log back in for changes to take effect!"
```

## Script 4: `03-migrate-docker.sh` - Migrate Docker

```bash
#!/bin/bash
# ============================================
# SCRIPT 3: Migrate Docker to HDD
# Usage: sudo ./03-migrate-docker.sh
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-config.sh"

echo "========================================="
echo "STEP 3: Migrate Docker to HDD"
echo "========================================="

if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run as root: sudo $0"
    exit 1
fi

if [ "$USE_DOCKER" != "yes" ]; then
    echo "Docker migration disabled in config"
    exit 0
fi

# Verify HDD is mounted
if ! mountpoint -q $HDD_MOUNT; then
    echo "❌ $HDD_MOUNT is not mounted"
    exit 1
fi

# Stop Docker
systemctl stop docker docker.socket 2>/dev/null

# Create Docker directory
mkdir -p $HDD_MOUNT/var/lib/docker

# Migrate existing Docker data
if [ -d "/var/lib/docker" ] && [ ! -L "/var/lib/docker" ]; then
    echo "Copying Docker data (may take a while)..."
    rsync -avxP --progress /var/lib/docker/ $HDD_MOUNT/var/lib/docker/
    mv /var/lib/docker /var/lib/docker.old
    echo "✅ Docker data copied"
fi

# Create symlink
ln -sf $HDD_MOUNT/var/lib/docker /var/lib/docker

# Create systemd override to wait for HDD
mkdir -p /etc/systemd/system/docker.service.d/
cat > /etc/systemd/system/docker.service.d/osa-wait.conf << EOF
[Unit]
Requires=$HDD_MOUNT
After=$HDD_MOUNT
After=local-fs.target
EOF

# Reload and start
systemctl daemon-reload
systemctl start docker

echo "✅ Docker migrated to HDD"
docker info | grep "Docker Root Dir"

echo "========================================="
echo "✅ DOCKER MIGRATION COMPLETE"
echo "========================================="
```

## Script 5: `04-migrate-mysql-zm.sh` - Migrate MySQL & ZoneMinder

```bash
#!/bin/bash
# ============================================
# SCRIPT 4: Migrate MySQL and ZoneMinder
# Usage: sudo ./04-migrate-mysql-zm.sh
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-config.sh"

echo "========================================="
echo "STEP 4: Migrate MySQL and ZoneMinder"
echo "========================================="

if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run as root: sudo $0"
    exit 1
fi

# Verify HDD is mounted
if ! mountpoint -q $HDD_MOUNT; then
    echo "❌ $HDD_MOUNT is not mounted"
    exit 1
fi

# Stop services
systemctl stop mysql zoneminder 2>/dev/null

# Create directories
mkdir -p $HDD_MOUNT/var/lib/mysql
mkdir -p $HDD_MOUNT/var/lib/zoneminder
mkdir -p $HDD_MOUNT/var/cache/zoneminder

# Function to create bind mount
create_bind_mount() {
    local source="$1"
    local target="$2"

    if [ -d "$source" ]; then
        # Backup original if exists and not a mount
        if [ -d "$target" ] && ! mountpoint -q "$target"; then
            mv "$target" "${target}.original"
        fi

        # Create target directory
        mkdir -p "$target"

        # Create bind mount
        mount --bind "$source" "$target"

        # Add to fstab if not exists
        if ! grep -q "$source $target" /etc/fstab; then
            echo "$source $target none bind 0 0" >> /etc/fstab
        fi

        echo "✅ Bind mount: $target → $source"
    fi
}

# Migrate MySQL
echo ""
echo "Migrating MySQL..."
if [ -d "/var/lib/mysql" ]; then
    rsync -avxP --progress /var/lib/mysql/ $HDD_MOUNT/var/lib/mysql/
    create_bind_mount "$HDD_MOUNT/var/lib/mysql" "/var/lib/mysql"

    # Fix permissions
    chown -R mysql:mysql /var/lib/mysql
    chmod 750 /var/lib/mysql
fi

# Migrate ZoneMinder
if [ "$USE_ZONEMINDER" = "yes" ]; then
    echo ""
    echo "Migrating ZoneMinder..."

    if [ -d "/var/lib/zoneminder" ]; then
        rsync -avxP --progress /var/lib/zoneminder/ $HDD_MOUNT/var/lib/zoneminder/
        create_bind_mount "$HDD_MOUNT/var/lib/zoneminder" "/var/lib/zoneminder"
        chown -R www-data:www-data /var/lib/zoneminder
    fi

    if [ -d "/var/cache/zoneminder" ]; then
        rsync -avxP --progress /var/cache/zoneminder/ $HDD_MOUNT/var/cache/zoneminder/
        create_bind_mount "$HDD_MOUNT/var/cache/zoneminder" "/var/cache/zoneminder"
        chown -R www-data:www-data /var/cache/zoneminder
    fi

    # Fix ZoneMinder config for MySQL socket
    if [ -f "/etc/zm/zm.conf" ]; then
        MYSQL_SOCK=$(mysql -e "SELECT @@socket;" 2>/dev/null | tail -1)
        sed -i "s|ZM_DB_SOCKET=.*|ZM_DB_SOCKET=$MYSQL_SOCK|" /etc/zm/zm.conf
    fi

    # Enable Apache config
    a2enconf zoneminder 2>/dev/null
    a2enmod rewrite cgi alias 2>/dev/null
fi

# Start services
systemctl start mysql
systemctl start zoneminder 2>/dev/null

echo ""
echo "========================================="
echo "✅ MYSQL AND ZONEMINDER MIGRATION COMPLETE"
echo "========================================="
```

## Script 6: `05-migrate-opt.sh` - Optional: Migrate /opt

```bash
#!/bin/bash
# ============================================
# SCRIPT 5: Migrate /opt to HDD (Optional)
# Usage: sudo ./05-migrate-opt.sh
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-config.sh"

echo "========================================="
echo "STEP 5: Migrate /opt to HDD (Optional)"
echo "========================================="

if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run as root: sudo $0"
    exit 1
fi

# Verify HDD is mounted
if ! mountpoint -q $HDD_MOUNT; then
    echo "❌ $HDD_MOUNT is not mounted"
    exit 1
fi

read -p "Migrate /opt to HDD? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "/opt" ] && [ ! -L "/opt" ]; then
        rsync -avxP --progress /opt/ $HDD_MOUNT/opt/
        mv /opt /opt.old
        ln -s $HDD_MOUNT/opt /opt
        echo "✅ /opt migrated"
    fi
fi

read -p "Migrate /usr/local to HDD? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "/usr/local" ] && [ ! -L "/usr/local" ]; then
        rsync -avxP --progress /usr/local/ $HDD_MOUNT/usr/local/
        mv /usr/local /usr/local.old
        ln -s $HDD_MOUNT/usr/local /usr/local
        echo "✅ /usr/local migrated"
    fi
fi

echo "========================================="
echo "✅ OPTIONAL MIGRATION COMPLETE"
echo "========================================="
```

## Script 7: `06-verify.sh` - Verify Everything

```bash
#!/bin/bash
# ============================================
# SCRIPT 6: Verify Migration
# Usage: ./06-verify.sh
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-config.sh"

echo "========================================="
echo "VERIFYING MIGRATION"
echo "========================================="

# Check HDD mount
echo ""
echo "📊 HDD MOUNT:"
if mountpoint -q $HDD_MOUNT; then
    echo "✅ $HDD_MOUNT is mounted"
    df -h $HDD_MOUNT | tail -1
else
    echo "❌ $HDD_MOUNT is NOT mounted"
fi

# Check symlinks
echo ""
echo "🔗 SYMLINKS:"
for link in /home /srv /opt /usr/local /var/lib/docker; do
    if [ -L "$link" ]; then
        echo "✅ $link → $(readlink -f $link)"
    fi
done

# Check bind mounts
echo ""
echo "🔗 BIND MOUNTS:"
mount | grep "/var/lib/mysql" && echo "✅ MySQL bind mount active" || echo "⚠️  MySQL bind mount not found"
mount | grep "/var/lib/zoneminder" && echo "✅ ZoneMinder bind mount active" || echo "⚠️  ZoneMinder bind mount not found"

# Check services
echo ""
echo "🖥️  SERVICES:"
for service in mysql docker zoneminder apache2; do
    if systemctl is-active --quiet $service 2>/dev/null; then
        echo "✅ $service is running"
    else
        echo "⚠️  $service is not running"
    fi
done

# Check ZoneMinder
if [ "$USE_ZONEMINDER" = "yes" ]; then
    echo ""
    echo "📹 ZONEMINDER:"
    if curl -s -o /dev/null -w "%{http_code}" http://localhost/zm | grep -q "200"; then
        echo "✅ Web interface accessible at http://localhost/zm"
    else
        echo "⚠️  Web interface not accessible"
    fi
fi

# Check Docker
if [ "$USE_DOCKER" = "yes" ]; then
    echo ""
    echo "🐳 DOCKER:"
    if docker info &>/dev/null; then
        echo "✅ Docker is working"
        docker info | grep "Docker Root Dir"
    else
        echo "⚠️  Docker not responding"
    fi
fi

# Summary
echo ""
echo "========================================="
echo "📊 DISK USAGE SUMMARY"
echo "========================================="
df -h / $HDD_MOUNT

echo ""
echo "========================================="
echo "✅ VERIFICATION COMPLETE"
echo "========================================="
```

## Master Script: `run-all.sh` - Run Everything

```bash
#!/bin/bash
# ============================================
# MASTER SCRIPT - Run all migrations
# Usage: sudo ./run-all.sh
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================="
echo "   COMPLETE SYSTEM MIGRATION TOOLKIT"
echo "========================================="
echo ""
echo "This script will migrate your system to use"
echo "a 1TB HDD for all large data."
echo ""
echo "⚠️  WARNING: This will modify your system!"
echo "Make sure you have backups before continuing."
echo ""
read -p "Continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

# Run scripts in order
echo ""
echo "Starting migration..."

"$SCRIPT_DIR/01-prepare-hdd.sh"
"$SCRIPT_DIR/02-migrate-home-srv.sh"

echo ""
echo "⚠️  You must log out and log back in now!"
read -p "Press Enter after you've logged back in..."

"$SCRIPT_DIR/03-migrate-docker.sh"
"$SCRIPT_DIR/04-migrate-mysql-zm.sh"
"$SCRIPT_DIR/05-migrate-opt.sh"
"$SCRIPT_DIR/06-verify.sh"

echo ""
echo "========================================="
echo "🎉 MIGRATION COMPLETE!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Reboot to test persistence: sudo reboot"
echo "2. After reboot, run ./06-verify.sh again"
echo "3. Remove old backups if everything works:"
echo "   sudo rm -rf /home.old /srv.old /var/lib/docker.old"
echo "========================================="
```

## Quick Setup Instructions

```bash
# 1. Create the toolkit directory
mkdir -p ~/migration-toolkit
cd ~/migration-toolkit

# 2. Copy all scripts above into files
# (Save each script with its respective name)

# 3. Make all scripts executable
chmod +x *.sh

# 4. Edit configuration (IMPORTANT!)
nano 00-config.sh
# Change HDD_DEV to your HDD (e.g., /dev/sdb)

# 5. Run the master script
sudo ./run-all.sh
```

## One-File Version (Simple Alternative)

If you prefer a single script:

```bash
#!/bin/bash
# ONE-FILE MIGRATION SCRIPT
# Edit these variables first:
HDD_DEV="/dev/sda"  # Change to your HDD
HDD_MOUNT="/osa"

# ... (combined version of all scripts above)
```

This toolkit will allow you to **reproduce the entire migration** on a fresh OS install by simply editing `00-config.sh` and running `sudo ./run-all.sh`.

Would you like me to create a single combined script instead of multiple files?