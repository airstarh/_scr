#!/bin/bash

# ============================================
# Fix VirtualBox Duplicate VM Error
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# VM path from your error
VM_PATH="/osa/_vbx/w11iot002/w11iot002.vbox"
VM_NAME="w11iot002"

print_status "Fixing VirtualBox duplicate VM error..."

# Method 1: List all registered VMs
print_status "Checking registered VMs..."
VBoxManage list vms

echo ""
print_status "Attempting to fix..."

# Try to unregister the existing VM if it exists
if VBoxManage showvminfo "$VM_NAME" &>/dev/null; then
    print_warning "VM '$VM_NAME' is already registered"
    print_status "Unregistering existing VM (keeping files)..."

    # Unregister but keep the files
    VBoxManage unregistervm "$VM_NAME" --keep

    if [ $? -eq 0 ]; then
        print_success "Existing VM unregistered successfully"
    else
        print_error "Failed to unregister VM"
    fi
else
    print_status "VM '$VM_NAME' not found in registry"
fi

# Now try to register the VM from its .vbox file
print_status "Registering VM from: $VM_PATH"

if [ -f "$VM_PATH" ]; then
    VBoxManage registervm "$VM_PATH"

    if [ $? -eq 0 ]; then
        print_success "VM registered successfully!"
    else
        print_error "Failed to register VM"
        print_status "Trying alternative method..."

        # Alternative: Create new VM and attach existing disk
        print_status "Creating new VM and attaching existing disk..."

        # Find the .vdi file
        VDI_FILE=$(find /osa/_vbx/w11iot002 -name "*.vdi" 2>/dev/null | head -1)

        if [ -n "$VDI_FILE" ]; then
            print_status "Found disk: $VDI_FILE"

            # Create new VM with different name to avoid conflict
            NEW_VM_NAME="${VM_NAME}_new"
            VBoxManage createvm --name "$NEW_VM_NAME" --register

            # Configure basic settings
            VBoxManage modifyvm "$NEW_VM_NAME" --memory 4096 --cpus 2
            VBoxManage modifyvm "$NEW_VM_NAME" --firmware efi

            # Create SATA controller
            VBoxManage storagectl "$NEW_VM_NAME" --name "SATA Controller" --add sata --bootable on

            # Attach existing disk
            VBoxManage storageattach "$NEW_VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VDI_FILE"

            print_success "New VM '$NEW_VM_NAME' created with your existing disk"
            print_status "You can now start '$NEW_VM_NAME' from VirtualBox GUI"
        else
            print_error "Could not find .vdi disk file"
        fi
    fi
else
    print_error "VM config file not found at: $VM_PATH"
    print_status "Please check if the path is correct"
fi

echo ""
print_status "Current registered VMs:"
VBoxManage list vms

echo ""
print_success "Fix completed!"
echo ""
echo "To start your VM:"
echo "1. Open VirtualBox GUI"
echo "2. Look for '$VM_NAME' or '${VM_NAME}_new'"
echo "3. Click Start"