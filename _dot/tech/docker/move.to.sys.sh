#!/bin/bash

# Stop all services
sudo systemctl stop docker
sudo systemctl stop docker.socket
sudo systemctl stop containerd

# Create main directory
sudo mkdir -p /mnt/d1001/dockersys

# Move Docker data
sudo mv /var/lib/docker/* /mnt/d1001/dockersys/ 2>/dev/null || true
sudo mv /var/lib/docker/.[!.]* /mnt/d1001/dockersys/ 2>/dev/null || true

# Move containerd data
sudo mv /var/lib/containerd/* /mnt/d1001/dockersys/ 2>/dev/null || true
sudo mv /var/lib/containerd/.[!.]* /mnt/d1001/dockersys/ 2>/dev/null || true

# Remove old empty directories
sudo rmdir /var/lib/docker 2>/dev/null || true
sudo rmdir /var/lib/containerd 2>/dev/null || true

# Configure Docker
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "data-root": "/mnt/d1001/dockersys"
}
EOF

# Configure containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's|root = "/var/lib/containerd"|root = "/mnt/d1001/dockersys"|g' /etc/containerd/config.toml

# Start services
sudo systemctl start containerd
sudo systemctl start docker

# Verify
sudo docker info | grep "Docker Root Dir"
sudo ls -la /mnt/d1001/dockersys/
