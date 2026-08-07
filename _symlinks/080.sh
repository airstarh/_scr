#!/bin/bash

# COMPLETE DOCKER REMOVAL SCRIPT
# This will completely remove Docker, containerd, and all data

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[✓]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }

if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root (use sudo)"
    exit 1
fi

print_warning "This will COMPLETELY REMOVE Docker, containerd, and ALL containers/images/volumes!"
read -p "Are you sure? Type 'yes' to continue: " confirm
if [ "$confirm" != "yes" ]; then
    print_error "Aborted"
    exit 1
fi

print_status "Stopping all Docker services..."
systemctl stop docker.socket docker containerd 2>/dev/null || true
killall -9 docker containerd dockerd containerd-shim 2>/dev/null || true
pkill -9 docker 2>/dev/null || true
pkill -9 containerd 2>/dev/null || true
sleep 3

print_status "Unmounting Docker bind mounts..."
umount -f /var/lib/containerd 2>/dev/null || true
umount -f /var/lib/docker 2>/dev/null || true
umount -f /osa/var/lib/containerd 2>/dev/null || true
umount -f /osa/var/lib/docker 2>/dev/null || true
sleep 2

print_status "Removing Docker data directories..."
rm -rf /var/lib/docker
rm -rf /var/lib/containerd
rm -rf /osa/docker
rm -rf /osa/containerd
rm -rf /osa/var/lib/docker
rm -rf /osa/var/lib/containerd
rm -rf /run/docker*
rm -rf /run/containerd*
rm -rf /etc/docker
rm -rf /etc/containerd
rm -f /etc/docker/daemon.json
rm -f /etc/containerd/config.toml

print_status "Removing fstab entries..."
sed -i '/docker/d' /etc/fstab
sed -i '/containerd/d' /etc/fstab

print_status "Removing Docker packages..."
apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
apt-get purge -y docker docker-engine docker.io containerd runc 2>/dev/null || true
apt-get autoremove -y 2>/dev/null || true

print_status "Removing Docker repositories..."
rm -f /etc/apt/sources.list.d/docker.list 2>/dev/null || true
rm -f /etc/apt/sources.list.d/docker-ce.list 2>/dev/null || true

print_status "Removing Docker GPG keys..."
rm -f /usr/share/keyrings/docker-archive-keyring.gpg 2>/dev/null || true
rm -f /etc/apt/keyrings/docker.gpg 2>/dev/null || true

print_status "Removing Docker group..."
groupdel docker 2>/dev/null || true

print_status "Cleaning system..."
apt-get update 2>/dev/null || true
apt-get autoremove -y 2>/dev/null || true
apt-get autoclean -y 2>/dev/null || true

print_status "Docker has been completely removed!"
print_status "To reinstall Docker, run:"
echo "  curl -fsSL https://get.docker.com | sh"
echo ""
print_warning "Reboot recommended: sudo reboot"
