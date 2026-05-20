#!/bin/bash

# DBeaver Installer Script for Kubuntu KDE Plasma 6.6
# Supports both DBeaver Community (Free) and DBeaver Universal (includes Pro features trial)

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    echo -e "${2}${1}${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check and install dependencies
check_dependencies() {
    print_message "Checking dependencies..." "$BLUE"

    local deps=("wget" "gpg" "apt-transport-https" "software-properties-common")
    local missing_deps=()

    for dep in "${deps[@]}"; do
        if ! command_exists "$dep"; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_message "Installing missing dependencies: ${missing_deps[*]}" "$YELLOW"
        sudo apt update
        sudo apt install -y "${missing_deps[@]}"
    fi

    print_message "✓ All dependencies satisfied" "$GREEN"
}

# Function to install via official repository (recommended)
install_via_repo() {
    print_message "Installing DBeaver via official repository..." "$BLUE"

    # Add DBeaver GPG key
    print_message "Adding DBeaver GPG key..." "$YELLOW"
    wget -qO - https://dbeaver.io/debs/dbeaver.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/dbeaver.gpg

    # Add DBeaver repository
    print_message "Adding DBeaver repository..." "$YELLOW"
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/dbeaver.gpg] https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list

    # Update package list
    print_message "Updating package list..." "$YELLOW"
    sudo apt update

    # Install DBeaver
    print_message "Installing DBeaver Community Edition..." "$YELLOW"
    sudo apt install -y dbeaver-ce

    print_message "✓ DBeaver installed successfully via repository!" "$GREEN"
}

# Function to install latest version via direct download
install_via_direct() {
    print_message "Installing latest DBeaver via direct download..." "$BLUE"

    # Get latest version URL
    print_message "Fetching latest DBeaver version..." "$YELLOW"
    LATEST_URL="https://dbeaver.io/files/dbeaver-ce-latest-linux.gtk.x86_64.tar.gz"
    DOWNLOAD_FILE="/tmp/dbeaver-latest.tar.gz"

    # Download DBeaver
    print_message "Downloading DBeaver..." "$YELLOW"
    wget -O "$DOWNLOAD_FILE" "$LATEST_URL"

    # Extract to /opt
    print_message "Extracting DBeaver..." "$YELLOW"
    sudo tar -xzf "$DOWNLOAD_FILE" -C /opt/

    # Create symbolic link
    sudo ln -sf /opt/dbeaver/dbeaver /usr/local/bin/dbeaver

    # Create desktop entry
    print_message "Creating desktop entry..." "$YELLOW"
    cat << EOF | sudo tee /usr/share/applications/dbeaver.desktop
[Desktop Entry]
Name=DBeaver Community
Comment=Universal Database Manager
Exec=/opt/dbeaver/dbeaver
Icon=/opt/dbeaver/icon.xpm
Terminal=false
Type=Application
Categories=Development;IDE;Database;
StartupWMClass=DBeaver
EOF

    # Clean up
    rm "$DOWNLOAD_FILE"

    print_message "✓ DBeaver installed successfully via direct download!" "$GREEN"
}

# Function to install using Snap (alternative method)
install_via_snap() {
    print_message "Installing DBeaver via Snap..." "$BLUE"

    if ! command_exists snap; then
        print_message "Snap is not installed. Installing Snap..." "$YELLOW"
        sudo apt update
        sudo apt install -y snapd
    fi

    print_message "Installing DBeaver from Snap Store..." "$YELLOW"
    sudo snap install dbeaver-ce

    print_message "✓ DBeaver installed successfully via Snap!" "$GREEN"
}

# Function to uninstall DBeaver
uninstall_dbeaver() {
    print_message "Uninstalling DBeaver..." "$RED"

    # Remove if installed via repository
    if dpkg -l | grep -q dbeaver-ce; then
        sudo apt remove -y dbeaver-ce
        sudo rm -f /etc/apt/sources.list.d/dbeaver.list
        sudo rm -f /usr/share/keyrings/dbeaver.gpg
    fi

    # Remove if installed via direct download
    if [ -d "/opt/dbeaver" ]; then
        sudo rm -rf /opt/dbeaver
        sudo rm -f /usr/local/bin/dbeaver
        sudo rm -f /usr/share/applications/dbeaver.desktop
    fi

    # Remove if installed via snap
    if snap list | grep -q dbeaver-ce; then
        sudo snap remove dbeaver-ce
    fi

    # Remove user configuration (optional)
    read -p "Do you want to remove user configuration? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf ~/.dbeaver4
        rm -rf ~/.local/share/DBeaverData
        print_message "User configuration removed." "$GREEN"
    fi

    print_message "✓ DBeaver uninstalled successfully!" "$GREEN"
}

# Main menu
main() {
    print_message "====================================" "$BLUE"
    print_message "    DBeaver Installation Script     " "$BLUE"
    print_message "   for Kubuntu KDE Plasma 6.6       " "$BLUE"
    print_message "====================================" "$BLUE"
    echo

    echo "Select installation method:"
    echo "1) Install via Official Repository (Recommended)"
    echo "2) Install via Direct Download (Latest version)"
    echo "3) Install via Snap (Alternative)"
    echo "4) Uninstall DBeaver"
    echo "5) Exit"
    echo
    read -p "Enter your choice (1-5): " choice

    case $choice in
        1)
            check_dependencies
            install_via_repo
            print_message "\nDBeaver has been installed successfully!" "$GREEN"
            print_message "You can launch it from application menu or by running 'dbeaver' in terminal" "$YELLOW"
            ;;
        2)
            check_dependencies
            install_via_direct
            print_message "\nDBeaver has been installed successfully!" "$GREEN"
            print_message "You can launch it from application menu or by running 'dbeaver' in terminal" "$YELLOW"
            ;;
        3)
            install_via_snap
            print_message "\nDBeaver has been installed successfully!" "$GREEN"
            print_message "You can launch it by running 'dbeaver-ce' in terminal" "$YELLOW"
            ;;
        4)
            uninstall_dbeaver
            ;;
        5)
            print_message "Exiting..." "$YELLOW"
            exit 0
            ;;
        *)
            print_message "Invalid choice! Please select 1-5" "$RED"
            exit 1
            ;;
    esac

    # Verify installation
    if [ "$choice" != "4" ] && [ "$choice" != "5" ]; then
        echo
        print_message "Verifying installation..." "$BLUE"
        if command_exists dbeaver || [ -f "/usr/local/bin/dbeaver" ] || snap list 2>/dev/null | grep -q dbeaver-ce; then
            print_message "✓ DBeaver is successfully installed and ready to use!" "$GREEN"
            print_message "\nTip: You may need to install Java if not already present:" "$YELLOW"
            print_message "  sudo apt install default-jre" "$YELLOW"
        else
            print_message "✗ Installation verification failed. Please check manually." "$RED"
        fi
    fi
}

# Run main function
main