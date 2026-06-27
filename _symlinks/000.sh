#!/usr/bin/env bash

set -euo pipefail

echo "Starting system cleanup..."

# APT cache and unused packages
sudo apt-get update
sudo apt-get -y autoremove --purge
sudo apt-get -y autoclean
sudo apt-get -y clean

# Remove orphaned packages (if deborphan is
