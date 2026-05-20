#!/bin/bash

echo "Installing Flatpak on Kubuntu 26..."

# Install Flatpak and KDE integration
sudo apt update
sudo apt install -y flatpak plasma-discover-backend-flatpak

# Add Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Restart Discover to show Flatpak apps
killall plasma-discover 2>/dev/null

echo "Done! Flatpak is now ready to use."
echo "You can now install apps with: flatpak install flathub <app-id>"