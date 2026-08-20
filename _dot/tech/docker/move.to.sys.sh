#!/bin/bash
set -e # Stop the script if any command fails

# --- Configuration ---
DOCKER_NEW_ROOT="/mnt/d1001/docker"
CONTAINERD_NEW_ROOT="/mnt/d1001/containerd"

# 1. Stop services
echo "Stopping Docker and Containerd services..."
sudo systemctl stop docker.socket docker containerd

# 2. Create target directories
echo "Creating new directories on HDD..."
sudo mkdir -p "$DOCKER_NEW_ROOT"
sudo mkdir -p "$CONTAINERD_NEW_ROOT"

# 3. Copy data safely using rsync (Preserves permissions and special files)
echo "Copying Docker data (this might take a while)..."
if [ -d /var/lib/docker ]; then
    sudo rsync -aHAX --info=progress2 /var/lib/docker/ "$DOCKER_NEW_ROOT/"
fi

echo "Copying containerd data..."
if [ -d /var/lib/containerd ]; then
    sudo rsync -aHAX --info=progress2 /var/lib/containerd/ "$CONTAINERD_NEW_ROOT/"
fi

# 4. Configure Docker daemon.json
echo "Updating Docker configuration..."
# This safely handles creating or merging with an existing daemon.json
if [ -f /etc/docker/daemon.json ]; then
    echo "Warning: /etc/docker/daemon.json already exists. Backing it up."
    sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak
fi

sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "data-root": "${DOCKER_NEW_ROOT}"
}
EOF

# 5. Configure containerd config.toml
echo "Updating containerd configuration..."
if [ -f /etc/containerd/config.toml ]; then
    sudo cp /etc/containerd/config.toml /etc/containerd/config.toml.bak
    sudo sed -i "s|/var/lib/containerd|${CONTAINERD_NEW_ROOT}|g" /etc/containerd/config.toml
else
    sudo mkdir -p /etc/containerd
    sudo containerd config default | sudo sed "s|/var/lib/containerd|${CONTAINERD_NEW_ROOT}|g" | sudo tee /etc/containerd/config.toml > /dev/null
fi

# 6. Start services
echo "Starting services..."
sudo systemctl start containerd
sudo systemctl start docker

# 7. Verification
echo "========================================="
echo "Verification:"
sudo docker info | grep "Docker Root Dir"
echo "========================================="
echo "If everything works perfectly, you can manually delete the old folders later using:"
echo "sudo rm -rf /var/lib/docker /var/lib/containerd"
