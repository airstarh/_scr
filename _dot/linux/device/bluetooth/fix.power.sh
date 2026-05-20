# region Temp
sudo sh -c 'echo on > /sys/bus/usb/devices/1-4.3/power/control'
cat /sys/bus/usb/devices/1-4.3/power/control
# endregion Temp

# 3. Fix the Bluetooth driver permanently:
# Create modprobe config to disable Bluetooth USB autosuspend
echo "options btusb enable_autosuspend=0" | sudo tee /etc/modprobe.d/btusb-noautosuspend.conf

# Remove and reload the Bluetooth module
sudo rmmod btusb
sudo modprobe btusb
sudo systemctl restart bluetooth