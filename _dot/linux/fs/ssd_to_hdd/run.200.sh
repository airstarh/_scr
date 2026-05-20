#!/bin/bash
# COMPLETE MIGRATION SCRIPT - Including ZoneMinder safety

set -e  # Stop on error

echo "========================================="
echo "STEP 0: Stop services that might be affected"
echo "========================================="
sudo systemctl stop zoneminder
sudo systemctl stop mysql
sudo systemctl stop docker docker.socket

echo -e "\n✅ Services stopped"

echo "========================================="
echo "STEP 1: Verify /osa is mounted"
echo "========================================="
mount | grep /osa

echo "========================================="
echo "STEP 2: Create FULL path structure on /osa"
echo "========================================="
sudo mkdir -p /osa/home
sudo mkdir -p /osa/srv
sudo mkdir -p /osa/var/lib/docker
sudo mkdir -p /osa/opt
sudo mkdir -p /osa/usr/local
echo "✅ Directories created"

echo "========================================="
echo "STEP 3: Move /home"
echo "========================================="
sudo rsync -avxP --progress /home/ /osa/home/
sudo mv /home /home.old
sudo ln -s /osa/home /home
echo "✅ /home moved to HDD"

echo "========================================="
echo "STEP 4: Move /srv"
echo "========================================="
sudo rsync -avxP --progress /srv/ /osa/srv/
sudo mv /srv /srv.old
sudo ln -s /osa/srv /srv
echo "✅ /srv moved to HDD"

echo "========================================="
echo "STEP 5: Move /var/lib/docker"
echo "========================================="
sudo rsync -avxP --progress /var/lib/docker/ /osa/var/lib/docker/
sudo mv /var/lib/docker /var/lib/docker.old
sudo ln -s /osa/var/lib/docker /var/lib/docker
echo "✅ Docker moved to HDD"

echo "========================================="
echo "STEP 6: Docker systemd configuration"
echo "========================================="
sudo mkdir -p /etc/systemd/system/docker.service.d/
sudo tee /etc/systemd/system/docker.service.d/osa-wait.conf << EOF
[Unit]
Requires=/osa
After=/osa
After=local-fs.target
EOF

sudo systemctl daemon-reload
echo "✅ Docker configured"

echo "========================================="
echo "STEP 7: Restart services"
echo "========================================="
sudo systemctl start mysql
sudo systemctl start docker
sudo systemctl start zoneminder
echo "✅ Services restarted"

echo "========================================="
echo "STEP 8: Verification"
echo "========================================="
echo "=== Symlink verification ==="
ls -la / | grep -E "home|srv"
ls -la /var/lib | grep docker

echo -e "\n=== Under /osa you'll see the SAME structure as / ==="
ls -la /osa/

echo -e "\n=== Docker root directory ==="
docker info | grep "Docker Root Dir"

echo -e "\n=== Disk usage ==="
df -h / /osa

echo -e "\n========================================="
echo "✅ MIGRATION COMPLETE!"
echo "========================================="
echo ""
echo "IMPORTANT: Log out and log back in for /home changes to take effect!"
echo ""
echo "After logging back in, verify:"
echo "  1. Your files are in ~/ (should show HDD content)"
echo "  2. ZoneMinder web UI: http://localhost/zm"
echo "  3. Docker: docker run hello-world"