#!/usr/bin/env bash
set -euo pipefail

# Remove apt cache
sudo apt clean
sudo apt autoremove -y

# Clear journal logs (keep last 10MB)
sudo journalctl --rotate
sudo journalctl --vacuum-size=10M

# Remove old dpkg logs
sudo find /var/log -name "*.gz" -type f -delete

# Clean tmp
sudo rm -rf /tmp/*

# Docker: remove unused images, dangling volumes, stopped containers
docker system prune -af

# Local build/cache dirs (adjust paths if needed)
rm -rf ~/.cache/*
rm -rf ~/Downloads/*.tmp

# Optional: clear browser caches (example for Firefox)
rm -rf ~/.mozilla/firefox/*.default*/cache2/*
