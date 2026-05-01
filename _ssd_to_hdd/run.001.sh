# ============================================
# STEP 1: Mount HDD to /osa (already done)
# ============================================
# Verify /osa is mounted
mount | grep /osa

# ============================================
# STEP 2: Create FULL path structure on /osa
# ============================================
# This mirrors your root filesystem structure
sudo mkdir -p /osa/home
sudo mkdir -p /osa/srv
sudo mkdir -p /osa/var/lib/docker
sudo mkdir -p /osa/opt            # For future
sudo mkdir -p /osa/usr/local      # For future

# ============================================
# STEP 3: Move /home (root-level, simple)
# ============================================
sudo rsync -avxP --progress /home/ /osa/home/
sudo mv /home /home.old
sudo ln -s /osa/home /home

# ============================================
# STEP 4: Move /srv (root-level, simple)
# ============================================
sudo rsync -avxP --progress /srv/ /osa/srv/
sudo mv /srv /srv.old
sudo ln -s /osa/srv /srv

# ============================================
# STEP 5: Move /var/lib/docker (PRESERVES FULL PATH)
# ============================================
sudo systemctl stop docker docker.socket

# Copy to exact same path under /osa
sudo rsync -avxP --progress /var/lib/docker/ /osa/var/lib/docker/

# Remove original (after confirming copy worked)
sudo mv /var/lib/docker /var/lib/docker.old

# Create symlink - NOTE the full path preservation
sudo ln -s /osa/var/lib/docker /var/lib/docker

# ============================================
# STEP 6: Docker systemd configuration
# ============================================
sudo mkdir -p /etc/systemd/system/docker.service.d/
sudo tee /etc/systemd/system/docker.service.d/osa-wait.conf << EOF
[Unit]
Requires=/osa
After=/osa
After=local-fs.target
EOF

sudo systemctl daemon-reload
sudo systemctl start docker

# ============================================
# STEP 7: Verify path preservation
# ============================================
echo "=== Symlink verification ==="
ls -la / | grep -E "home|srv"
ls -la /var/lib | grep docker

echo -e "\n=== Under /osa you'll see the SAME structure as / ==="
ls -la /osa/

echo -e "\n=== Docker root directory ==="
docker info | grep "Docker Root Dir"

# ============================================
# STEP 8: Check disk usage
# ============================================
df -h / /osa