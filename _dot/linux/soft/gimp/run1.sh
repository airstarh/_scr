#!/bin/bash

# ============================================
# GIMP Installation Script for Kubuntu 26
# KDE Plasma 6.6 Wayland
# ============================================

set -e  # Exit on error

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Display menu
show_menu() {
    echo ""
    echo "========================================="
    echo "     GIMP Installation Methods"
    echo "========================================="
    echo "1) APT (Recommended - system package)"
    echo "2) Flatpak (Latest version - official GIMP)"
    echo "3) Snap (Universal package)"
    echo "4) Check if GIMP is already installed"
    echo "5) Remove GIMP (all methods)"
    echo "6) Exit"
    echo "========================================="
}

# Install via APT
install_apt() {
    print_info "Installing GIMP via APT..."
    sudo apt update
    sudo apt install -y gimp
    print_success "GIMP installed via APT"
    print_info "You can launch GIMP from your application menu or by typing 'gimp' in terminal"
}

# Install via Flatpak
install_flatpak() {
    print_info "Checking Flatpak installation..."
    if ! command -v flatpak &> /dev/null; then
        print_warning "Flatpak not found. Installing Flatpak..."
        sudo apt update
        sudo apt install -y flatpak
    fi
    
    print_info "Adding Flathub repository..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    
    print_info "Installing GIMP from Flathub..."
    flatpak install -y flathub org.gimp.GIMP
    
    print_success "GIMP installed via Flatpak"
    print_info "Launch GIMP by typing 'flatpak run org.gimp.GIMP' or from your application menu"
}

# Install via Snap
install_snap() {
    print_info "Checking Snap installation..."
    if ! command -v snap &> /dev/null; then
        print_warning "Snap not found. Installing Snapd..."
        sudo apt update
        sudo apt install -y snapd
        sudo systemctl start snapd
        sudo systemctl enable snapd
    fi
    
    print_info "Installing GIMP via Snap..."
    sudo snap install gimp
    
    print_success "GIMP installed via Snap"
    print_info "Launch GIMP from your application menu or by typing 'gimp' in terminal"
}

# Check if GIMP is installed
check_installed() {
    echo ""
    print_info "Checking for GIMP installations..."
    echo "----------------------------------------"
    
    if command -v gimp &> /dev/null; then
        echo -e "${GREEN}✓ APT version:${NC} $(gimp --version 2>/dev/null | head -1 || echo 'installed')"
    else
        echo -e "${RED}✗ APT version:${NC} not found"
    fi
    
    if flatpak list 2>/dev/null | grep -q org.gimp.GIMP; then
        echo -e "${GREEN}✓ Flatpak version:${NC} installed"
    else
        echo -e "${RED}✗ Flatpak version:${NC} not found"
    fi
    
    if snap list 2>/dev/null | grep -q gimp; then
        echo -e "${GREEN}✓ Snap version:${NC} installed"
    else
        echo -e "${RED}✗ Snap version:${NC} not found"
    fi
    
    echo "----------------------------------------"
}

# Remove all GIMP installations
remove_all() {
    print_warning "This will remove GIMP installations from APT, Flatpak, and Snap"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Removing APT version..."
        sudo apt remove -y gimp 2>/dev/null || true
        
        print_info "Removing Flatpak version..."
        flatpak uninstall -y org.gimp.GIMP 2>/dev/null || true
        
        print_info "Removing Snap version..."
        sudo snap remove gimp 2>/dev/null || true
        
        print_success "All GIMP installations removed"
    else
        print_info "Cancelled"
    fi
}

# Main loop
while true; do
    show_menu
    read -p "Choose an option [1-6]: " choice
    case $choice in
        1) install_apt; break ;;
        2) install_flatpak; break ;;
        3) install_snap; break ;;
        4) check_installed; read -p "Press Enter to continue..." ;;
        5) remove_all ;;
        6) print_info "Exiting..."; exit 0 ;;
        *) print_warning "Invalid option. Please choose 1-6." ;;
    esac
done

print_success "Done!"