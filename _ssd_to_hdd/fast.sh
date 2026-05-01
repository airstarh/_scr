# Option A: If /var/lib/zoneminder was empty, run these:
sudo rm -rf /var/lib/zoneminder
sudo mkdir -p /var/lib/zoneminder /osa/var/lib/zoneminder
sudo chown www-data:www-data /osa/var/lib/zoneminder
sudo mount --bind /osa/var/lib/zoneminder /var/lib/zoneminder
echo '/osa/var/lib/zoneminder /var/lib/zoneminder none bind 0 0' | sudo tee -a /etc/fstab

# Check if /var/cache/zoneminder exists and has data
if [ -d /var/cache/zoneminder ]; then
    echo "Moving /var/cache/zoneminder..."
    sudo rsync -avxP /var/cache/zoneminder/ /osa/var/cache/zoneminder/
    sudo mv /var/cache/zoneminder /var/cache/zoneminder.original
    sudo mkdir -p /var/cache/zoneminder
    sudo mount --bind /osa/var/cache/zoneminder /var/cache/zoneminder
    echo '/osa/var/cache/zoneminder /var/cache/zoneminder none bind 0 0' | sudo tee -a /etc/fstab
fi

# Now start services
sudo systemctl start mysql
sudo systemctl start zoneminder

# Check status
sudo systemctl status zoneminder --no-pager