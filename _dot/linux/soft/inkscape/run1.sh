a#!/bin/bash

# Simple Inkscape installer for Kubuntu Wayland
# KDE Plasma 6.6 compatible

set -e

echo "Installing Inkscape on Kubuntu Wayland..."

# Update package list
sudo apt update

# Install Inkscape and KDE integration
sudo apt install -y inkscape

# Install optional KDE file thumbnails for SVG/PS/EPS
sudo apt install -y kdegraphics-thumbnailers

# Verify installation
if command -v inkscape &> /dev/null; then
    echo ""
    echo "✓ Inkscape installed successfully!"
    inkscape --version
    echo ""
    echo "You can now run Inkscape from:"
    echo "  - Application Launcher (search 'Inkscape')"
    echo "  - Terminal: inkscape"
    echo ""
    echo "For EPS to SVG conversion:"
    echo "  inkscape --export-type=svg input.eps"
else
    echo "✗ Installation failed"
    exit 1
fi