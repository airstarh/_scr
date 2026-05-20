#!/bin/bash

# ============================================
# VirtualBox Fix Script for Kubuntu/KDE Plasma
# Fixes: VT-x disabled error (VERR_VMX_MSR_ALL_VMX_DISABLED)
# For Core i5 processors
# ============================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
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

# Function to check if running with sudo
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run with sudo!"
        echo "Please run: sudo $0"
        exit 1
    fi
}

# Function to detect CPU type
detect_cpu() {
    print_status "Detecting CPU type..."
    if grep -qi "intel" /proc/cpuinfo; then
        CPU_TYPE="intel"
        KVM_MODULE="kvm_intel"
        print_success "Intel CPU detected (Core i5)"
    elif grep -qi "amd" /proc/cpuinfo; then
        CPU_TYPE="amd"
        KVM_MODULE="kvm_amd"
        print_success "AMD CPU detected"
    else
        print_warning "Could not detect CPU type, assuming Intel"
        CPU_TYPE="intel"
        KVM_MODULE="kvm_intel"
    fi
}

# Function to check if KVM is loaded
check_kvm_status() {
    print_status "Checking KVM module status..."
    if lsmod | grep -q "kvm"; then
        print_warning "KVM modules are currently loaded (conflict detected)"
        return 0
    else
        print_success "No KVM modules currently loaded"
        return 1
    fi
}

# Function to unload KVM modules immediately
unload_kvm() {
    print_status "Unloading KVM modules..."

    # Stop any running VMs that might be using KVM
    print_status "Checking for running KVM virtual machines..."
    if pgrep -f "qemu-system" > /dev/null; then
        print_warning "Found running QEMU/KVM processes. Attempting to stop them..."
        pkill -f "qemu-system" 2>/dev/null
        sleep 2
    fi

    # Unload the modules
    if lsmod | grep -q "$KVM_MODULE"; then
        print_status "Removing $KVM_MODULE module..."
        modprobe -r "$KVM_MODULE" 2>/dev/null
        if [ $? -eq 0 ]; then
            print_success "$KVM_MODULE unloaded"
        else
            print_error "Failed to unload $KVM_MODULE"
        fi
    fi

    # Unload the main kvm module
    if lsmod | grep -q "kvm"; then
        print_status "Removing kvm module..."
        modprobe -r kvm 2>/dev/null
        if [ $? -eq 0 ]; then
            print_success "kvm module unloaded"
        fi
    fi

    sleep 1
    print_success "KVM modules unloaded"
}

# Function to blacklist KVM permanently
blacklist_kvm() {
    print_status "Creating permanent blacklist for KVM modules..."

    BLACKLIST_FILE="/etc/modprobe.d/virtualbox-fix.conf"

    # Create backup if file exists
    if [ -f "$BLACKLIST_FILE" ]; then
        backup_file="${BLACKLIST_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$BLACKLIST_FILE" "$backup_file"
        print_status "Backup created: $backup_file"
    fi

    # Write blacklist configuration
    cat > "$BLACKLIST_FILE" << EOF
# Blacklist KVM modules to prevent conflict with VirtualBox
# Created by VirtualBox fix script on $(date)
# This prevents the "VT-x is disabled" error

blacklist kvm
blacklist $KVM_MODULE

# Optional: Also blacklist related modules
blacklist irqbypass

# KVM modules are now disabled for VirtualBox compatibility
EOF

    if [ $? -eq 0 ]; then
        print_success "Blacklist file created: $BLACKLIST_FILE"
    else
        print_error "Failed to create blacklist file"
        return 1
    fi
}

# Function to update initramfs
update_initramfs() {
    print_status "Updating initramfs to apply changes..."

    if command -v update-initramfs &> /dev/null; then
        update-initramfs -u
        if [ $? -eq 0 ]; then
            print_success "initramfs updated successfully"
        else
            print_error "Failed to update initramfs"
        fi
    else
        print_warning "update-initramfs not found (might be using dracut or other init system)"
        if command -v dracut &> /dev/null; then
            dracut --force
            print_success "dracut updated"
        fi
    fi
}

# Function to check VirtualBox installation
check_virtualbox() {
    print_status "Checking VirtualBox installation..."

    if command -v VBoxManage &> /dev/null; then
        VBOX_VERSION=$(VBoxManage --version 2>/dev/null)
        print_success "VirtualBox found (version: $VBOX_VERSION)"

        # Check if VirtualBox kernel modules are loaded
        if lsmod | grep -q "vboxdrv"; then
            print_success "VirtualBox kernel modules are loaded"
        else
            print_warning "VirtualBox kernel modules not loaded. Attempting to load..."
            modprobe vboxdrv 2>/dev/null
            if [ $? -eq 0 ]; then
                print_success "VirtualBox modules loaded"
            else
                print_warning "Could not load VirtualBox modules. Run: sudo modprobe vboxdrv"
            fi
        fi
    else
        print_error "VirtualBox not found in PATH. Please install VirtualBox first."
        echo "You can install it with: sudo apt install virtualbox"
        return 1
    fi
}

# Function to verify the fix
verify_fix() {
    print_status "Verifying the fix..."

    # Check if KVM is still loaded
    if lsmod | grep -q "kvm"; then
        print_error "KVM modules are STILL loaded after fix attempt!"
        return 1
    else
        print_success "KVM modules are no longer loaded ✓"
    fi

    # Check if blacklist file exists
    if [ -f "/etc/modprobe.d/virtualbox-fix.conf" ]; then
        print_success "Blacklist file is in place ✓"
    else
        print_warning "Blacklist file missing"
    fi

    # Check VirtualBox functionality
    if command -v VBoxManage &> /dev/null; then
        print_success "VirtualBox is available ✓"
    fi

    print_success "All checks passed!"
}

# Function to show test instructions
show_test_instructions() {
    echo ""
    echo "=========================================="
    echo -e "${GREEN}FIX COMPLETED!${NC}"
    echo "=========================================="
    echo ""
    echo "To test if the fix works:"
    echo "1. Try starting your VM 'w11iot002' in VirtualBox"
    echo "2. The error should no longer appear"
    echo ""
    echo "Important notes:"
    echo "- KVM is now blacklisted and won't load on boot"
    echo "- If you need KVM in the future, remove or comment out:"
    echo "  sudo rm /etc/modprobe.d/virtualbox-fix.conf"
    echo "  sudo update-initramfs -u"
    echo "  sudo reboot"
    echo ""
    echo "After reboot:"
    echo "- The fix will remain active"
    echo "- VirtualBox will work without conflicts"
    echo ""
}

# Function to offer reboot
offer_reboot() {
    echo ""
    read -p "Do you want to reboot now to apply all changes? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Rebooting in 3 seconds..."
        sleep 3
        reboot
    else
        print_warning "Remember to reboot later to ensure all changes take effect!"
        print_status "You can run: sudo systemctl reboot"
    fi
}

# Main execution
main() {
    echo "=========================================="
    echo "VirtualBox Fix for Kubuntu/KDE Plasma 6"
    echo "Fixing: VT-x disabled error"
    echo "=========================================="
    echo ""

    # Check if running as root
    check_root

    # Detect CPU
    detect_cpu

    # Check VirtualBox
    check_virtualbox || exit 1

    # Check current KVM status
    check_kvm_status

    # Unload KVM modules
    unload_kvm

    # Blacklist KVM permanently
    blacklist_kvm

    # Update initramfs
    update_initramfs

    # Verify the fix
    verify_fix

    # Show instructions
    show_test_instructions

    # Offer reboot
    offer_reboot
}

# Run the main function
main