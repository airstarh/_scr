Ah, perfect! Thank you for clarifying. Now everything makes sense.

So you have:
- **Bluetooth mouse:** Logitech MX Master 2S (connected via the Realtek Bluetooth adapter - Device 006)
- **No wired mouse** currently plugged in
- Everything runs through USB hubs

## Your freeze issue is almost certainly Bluetooth power management

The Realtek Bluetooth adapter (ID 0bda:8771) is aggressively power-saving, causing the MX Master 2S to disconnect/freeze.

## Immediate fix (apply now):

### 1. Fix the Bluetooth adapter power management:
```bash
# Disable autosuspend for the Realtek Bluetooth adapter
sudo sh -c 'echo on > /sys/bus/usb/devices/1-4.3/power/control'
```

### 2. Verify it worked:
```bash
cat /sys/bus/usb/devices/1-4.3/power/control
```
Should show `on`

### 3. Fix the Bluetooth driver permanently:
```bash
# Create modprobe config to disable Bluetooth USB autosuspend
echo "options btusb enable_autosuspend=0" | sudo tee /etc/modprobe.d/btusb-noautosuspend.conf

# Remove and reload the Bluetooth module
sudo rmmod btusb
sudo modprobe btusb
sudo systemctl restart bluetooth
```

## Permanent fix (survives reboot):

### 1. Create the udev rule:
```bash
sudo nano /etc/udev/rules.d/99-bluetooth-power.rules
```

Add this line (targets your specific Realtek adapter):
```
# Disable USB autosuspend for Realtek Bluetooth adapter (Logitech MX Master 2S)
ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="8771", ATTR{power/control}="on"
```

Save (Ctrl+O, then Ctrl+X)

### 2. Reload udev:
```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

### 3. Also prevent Bluetooth power management at the kernel level:
```bash
sudo nano /etc/modprobe.d/bluetooth-poweroff.conf
```

Add:
```
options btusb enable_autosuspend=0
options bluetooth power_save=0
```

### 4. Update GRUB again (double-check):
```bash
sudo nano /etc/default/grub
```

Make sure your GRUB_CMDLINE_LINUX_DEFAULT line looks like:
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash usbcore.autosuspend=-1"
```

Then:
```bash
sudo update-grub
```

## For your Logitech MX Master 2S specifically:

Install Solaar (Logitech device manager) for better control:
```bash
sudo apt install solaar
```

Launch it:
```bash
solaar
```

In Solaar, you can:
- Check battery status
- Disable any power saving features
- See connection status

## Test after applying:

1. **Reboot:**
```bash
sudo reboot
```

2. **After reboot, verify all settings:**
```bash
# Check USB power status
cat /sys/bus/usb/devices/1-4.3/power/control

# Check Bluetooth module parameters
cat /sys/module/btusb/parameters/enable_autosuspend

# Check Bluetooth status
sudo systemctl status bluetooth
```

3. **Monitor for freezes:**
```bash
# Watch for Bluetooth disconnections
sudo dmesg -w | grep -E "bluetooth|btusb|usb"
```

## If the mouse still freezes occasionally:

Try re-pairing the MX Master 2S with a fresh connection:
```bash
# Remove the device
bluetoothctl
remove XX:XX:XX:XX:XX:XX  # Your MX Master's MAC address
scan on
# Re-pair when found
```

**The combination of disabling USB autosuspend + btusb autosuspend should completely fix your issue.** The MX Master 2S is known to be sensitive to power management on Linux. Let me know if you still experience freezes after reboot!