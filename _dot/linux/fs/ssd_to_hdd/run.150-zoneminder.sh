# Step 1: Stop ZoneMinder completely
sudo systemctl stop zoneminder
sudo systemctl stop mysql  # or mariadb

# Step 2: Copy data to /osa preserving full paths
sudo mkdir -p /osa/var/lib/zoneminder
sudo rsync -avxP /var/lib/zoneminder/ /osa/var/lib/zoneminder/

# Step 3: Rename original (backup)
sudo mv /var/lib/zoneminder /var/lib/zoneminder.old

# Step 4: Use BIND MOUNT (not symlink) - more reliable for ZM
sudo mkdir -p /var/lib/zoneminder
sudo mount --bind /osa/var/lib/zoneminder /var/lib/zoneminder

### AFTER SCTIP EXECUTED:
### # Add this line to /etc/fstab
### s/osa/var/lib/zoneminder /var/lib/zoneminder none bind 0 0