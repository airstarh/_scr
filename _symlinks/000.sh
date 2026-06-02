#!/bin/bash
# Install GitFourchette via Flatpak
sudo apt update
sudo apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub org.gitfourchette.gitfourchette