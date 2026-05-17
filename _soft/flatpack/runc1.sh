#!/usr/bin/bash

# =============================================================================
# Flatpak Package Manager for Kubuntu 26
# =============================================================================
# This script provides automated management of Flatpak packages including:
# - Initial Flatpak setup and Flathub repository configuration
# - Installation of common applications
# - System updates and maintenance
# - Permission management
# =============================================================================

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Color codes for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FLATHUB_REPO="https://dl.flathub.org/repo/flathub.flatpakrepo"
LOG_FILE="$HOME/.flatpak-manager.log"

# =============================================================================
# Helper Functions
# =============================================================================

log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}   $1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_error "$1 is not installed"
        return 1
    fi
    return 0
}

# =============================================================================
# Setup Functions
# =============================================================================

setup_flatpak() {
    print_header "Setting up Flatpak on Kubuntu 26"
    
    # Check if Flatpak is already installed
    if command -v flatpak &> /dev/null; then
        print_success "Flatpak is already installed"
        local version=$(flatpak --version)
        log "Flatpak version: $version"
    else
        print_warning "Flatpak not found. Installing..."
        log "Installing Flatpak packages"
        
        sudo apt update
        sudo apt install -y flatpak plasma-discover-backend-flatpak kde-config-flatpak
        
        if [ $? -eq 0 ]; then
            print_success "Flatpak installed successfully"
        else
            print_error "Failed to install Flatpak"
            exit 1
        fi
    fi
    
    # Add Flathub repository if not already present
    print_warning "Configuring Flathub repository..."
    
    if flatpak remotes | grep -q "flathub"; then
        print_success "Flathub repository already configured"
    else
        flatpak remote-add --if-not-exists flathub "$FLATHUB_REPO"
        print_success "Flathub repository added"
    fi
    
    log "Flatpak setup completed"
}

# =============================================================================
# Package Management Functions
# =============================================================================

install_flatpaks() {
    print_header "Installing Flatpak Applications"
    
    # Define common applications to install
    declare -a APPS=(
        "com.github.tchx84.Flatseal"        # Flatpak permission manager
        "com.visualstudio.code"             # VS Code
        "org.mozilla.firefox"               # Firefox browser
        "org.videolan.VLC"                  # VLC media player
        "com.spotify.Client"                # Spotify
        "com.discordapp.Discord"            # Discord
        "org.telegram.desktop"              # Telegram
        "org.libreoffice.LibreOffice"       # LibreOffice suite
        "org.gimp.GIMP"                     # GIMP image editor
        "org.kde.kdenlive"                  # Kdenlive video editor
        "com.bitwarden.desktop"             # Bitwarden password manager
        "org.signal.Signal"                 # Signal messenger
        "com.valvesoftware.Steam"           # Steam gaming platform
    )
    
    local installed=0
    local failed=0
    
    for app in "${APPS[@]}"; do
        echo -n "Installing $app... "
        
        if flatpak list | grep -q "$app"; then
            print_success "$app already installed"
            ((installed++))
        else
            if flatpak install -y flathub "$app" &> /dev/null; then
                print_success "$app installed successfully"
                log "Installed: $app"
                ((installed++))
            else
                print_error "Failed to install $app"
                log "Failed to install: $app"
                ((failed++))
            fi
        fi
    done
    
    echo -e "\n${GREEN}Installation Summary:${NC}"
    echo "  ✓ Installed/Skipped: $installed"
    echo "  ✗ Failed: $failed"
}

install_custom_flatpak() {
    print_header "Install Custom Flatpak Application"
    
    read -p "Enter Flatpak application ID (e.g., org.example.app): " app_id
    
    if [ -z "$app_id" ]; then
        print_error "No application ID provided"
        return 1
    fi
    
    echo "Searching for $app_id..."
    flatpak search "$app_id" --columns=application,name
    
    read -p "Install $app_id? (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        flatpak install -y flathub "$app_id"
        if [ $? -eq 0 ]; then
            print_success "$app_id installed successfully"
            log "Installed custom: $app_id"
        else
            print_error "Failed to install $app_id"
        fi
    fi
}

# =============================================================================
# Maintenance Functions
# =============================================================================

update_flatpaks() {
    print_header "Updating Flatpak Applications"
    
    log "Checking for Flatpak updates"
    
    # Check for updates first
    local updates=$(flatpak update --dry-run 2>&1 | grep -c "Update:" || true)
    
    if [ "$updates" -eq 0 ]; then
        print_success "All Flatpaks are up to date"
    else
        print_warning "Found $updates available updates"
        flatpak update -y
        
        if [ $? -eq 0 ]; then
            print_success "All Flatpaks updated successfully"
            log "Flatpak update completed"
        else
            print_error "Some updates failed"
        fi
    fi
}

cleanup_flatpaks() {
    print_header "Cleaning Up Flatpak"
    
    log "Removing unused Flatpak packages"
    
    # Remove unused runtimes and extensions
    local removed=$(flatpak uninstall --unused -y 2>&1 | grep -c "removed" || true)
    
    if [ "$removed" -gt 0 ]; then
        print_success "Removed $removed unused packages"
    else
        print_success "No unused packages to remove"
    fi
    
    # Clean up temporary files
    flatpak repair --user
    
    print_success "Cleanup completed"
    log "Cleanup completed"
}

list_installed() {
    print_header "Installed Flatpak Applications"
    
    if flatpak list --columns=application,name,version,origin | grep -q "."; then
        flatpak list --columns=application,name,version,origin
    else
        print_warning "No Flatpaks installed"
    fi
}

show_permissions() {
    print_header "Flatpak Permission Manager"
    
    print_warning "Opening Flatseal permission manager..."
    
    if flatpak list | grep -q "com.github.tchx84.Flatseal"; then
        flatpak run com.github.tchx84.Flatseal
    else
        print_warning "Flatseal is not installed. Installing now..."
        flatpak install -y flathub com.github.tchx84.Flatseal
        flatpak run com.github.tchx84.Flatseal
    fi
}

# =============================================================================
# Main Menu
# =============================================================================

show_menu() {
    clear
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════╗"
    echo "║     Flatpak Package Manager v1.0       ║"
    echo "║        For Kubuntu 26 Focus            ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
    echo "1. Setup Flatpak (First-time configuration)"
    echo "2. Install recommended applications"
    echo "3. Install custom Flatpak application"
    echo "4. Update all Flatpaks"
    echo "5. Clean up unused packages"
    echo "6. List installed applications"
    echo "7. Manage application permissions (Flatseal)"
    echo "8. Run complete system maintenance"
    echo "9. Exit"
    echo ""
    echo -n "Select an option [1-9]: "
}

run_maintenance() {
    print_header "Running Complete System Maintenance"
    
    update_flatpaks
    cleanup_flatpaks
    list_installed
    
    print_success "Maintenance completed!"
    log "Full maintenance cycle completed"
}

# =============================================================================
# Main Execution
# =============================================================================

main() {
    # Check for sudo access
    if ! sudo -n true 2>/dev/null; then
        print_warning "This script requires sudo privileges for setup operations"
    fi
    
    while true; do
        show_menu
        read choice
        
        case $choice in
            1)
                setup_flatpak
                read -p "Press Enter to continue..."
                ;;
            2)
                install_flatpaks
                read -p "Press Enter to continue..."
                ;;
            3)
                install_custom_flatpak
                read -p "Press Enter to continue..."
                ;;
            4)
                update_flatpaks
                read -p "Press Enter to continue..."
                ;;
            5)
                cleanup_flatpaks
                read -p "Press Enter to continue..."
                ;;
            6)
                list_installed
                read -p "Press Enter to continue..."
                ;;
            7)
                show_permissions
                read -p "Press Enter to continue..."
                ;;
            8)
                run_maintenance
                read -p "Press Enter to continue..."
                ;;
            9)
                print_success "Exiting Flatpak Manager. Goodbye!"
                log "Script exited normally"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please try again."
                sleep 1
                ;;
        esac
    done
}

# Run the main function
main