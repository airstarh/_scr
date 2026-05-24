#!/bin/bash

echo "=== SYSTEM REPORT $(date) ==="
echo

echo "[1] HOSTNAME AND KERNEL"
hostname
uname -a
echo

echo "[2] CPU DETAILS"
echo "--- /proc/cpuinfo ---"
grep -E "^model name|^cpu cores|^siblings|^flags" /proc/cpuinfo | uniq
echo
echo "--- lscpu ---"
lscpu | grep -E "Model name|CPU\(s\)|Thread|Core|Vendor|Architecture|Virtualization"
echo

echo "[3] VIRTUALIZATION FLAGS"
echo "VT-x/AMD-V check:"
grep -Eo "(vmx|svm)" /proc/cpuinfo | sort | uniq -c || echo "No virtualization flags found"
echo "KVM status:"
if command -v kvm-ok &> /dev/null; then
    sudo kvm-ok 2>&1
else
    echo "kvm-ok not installed (run: sudo apt install cpu-checker)"
fi
echo

echo "[4] MOTHERBOARD AND BIOS"
echo "--- dmidecode (system) ---"
sudo dmidecode -t system 2>/dev/null | grep -E "Manufacturer|Product|Serial|UUID" || echo "dmidecode: access denied or not available"
echo "--- dmidecode (baseboard) ---"
sudo dmidecode -t baseboard 2>/dev/null | grep -E "Manufacturer|Product|Version|Serial" || echo "dmidecode: access denied or not available"
echo "--- dmidecode (BIOS) ---"
sudo dmidecode -t bios 2>/dev/null | grep -E "Vendor|Version|Release" || echo "dmidecode: access denied or not available"
echo

echo "[5] CPU SOCKET AND PHYSICAL INFO"
sudo dmidecode -t processor 2>/dev/null | grep -E "Socket|Manufacturer|Version|Max Speed|Current Speed|Core Count|Thread Count" || echo "dmidecode: access denied or not available"
echo

echo "[6] PCI DEVICES (for context)"
lspci -nn | head -10
echo

echo "[7] IOMMU/DMAR STATUS"
sudo dmesg | grep -i "iommu\|dmar" | tail -15
echo

echo "[8] LSMOD FOR VIRTUALIZATION"
lsmod | grep -E "(kvm|vbox)" || echo "No relevant modules loaded"
echo

echo "=== END REPORT ==="
