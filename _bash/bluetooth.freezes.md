It looks like your issue is a persistent system-level conflict or power management setting, as both wired and wireless mice are affected. Here’s how to troubleshoot this via Terminal.

### 1. Disable USB Autosuspend (most likely fix for wired mice)
The kernel often suspends USB ports to save power, which can cause wired mice to freeze.
*   **Check current status:** Look for the USB port your mouse is connected to, then check if it's suspended: `lsusb` then `cat /sys/bus/usb/devices/X/power/runtime_status`
*   **Test temporary fix:** Disable autosuspend for all USB devices: `echo -1 | sudo tee /sys/module/usbcore/parameters/autosuspend`
*   **Make permanent:** Edit the GRUB file: `sudo nano /etc/default/grub`
    *   Find the line `GRUB_CMDLINE_LINUX_DEFAULT`. Add `usbcore.autosuspend=-1` inside the quotes.
    *   Save, then update: `sudo update-grub` and reboot.

### 2. Disable Bluetooth Power Management
Modern kernels use power-saving features on Bluetooth controllers.
*   **Permanent fix:** Create a configuration file: `sudo nano /etc/modprobe.d/bluetooth-poweroff.conf`
*   **Add this line:** `options btusb enable_autosuspend=n`
*   Save, then restart the Bluetooth service: `sudo systemctl restart bluetooth` (or reboot).

### 3. Reset the Input Subsystem
If the mouse freezes but the system is still responsive, try resetting the driver without a full reboot.
*   **For Wired:** Reload the USB HID module: `sudo rmmod usbhid && sudo modprobe usbhid`
*   **For Bluetooth:** Restart the service: `sudo systemctl restart bluetooth`

### 4. Check for IRQ Conflicts or High Interrupts
Sometimes other devices hog the system bus. Check if the CPU is dropping interrupts:
*   `grep -i "irq" /var/log/syslog | tail -20`
*   `cat /proc/interrupts | grep -i "usb\|mouse"`

**Pro tip:** Even after these fixes, interference (USB 3.0 nearest the dongle, or WiFi on the 2.4GHz band) can cause similar symptoms. Try plugging the receiver into a USB 2.0 port if available, or switching WiFi to 5GHz. Let me know if the Terminal commands reveal any specific errors.


This is a frustrating issue, especially since you've already confirmed the hardware is healthy. On Kubuntu (or any Linux distribution), a "freezing" Bluetooth mouse is rarely a sign of a bad signal, but often a sign that the system is having trouble processing the mouse's data stream—specifically its **HID (Human Interface Device) report descriptor** .

Here’s how to diagnose and fix it.

### Step 1: Identify the Culprit (The Logs)
First, let's see if Linux is throwing errors when the freeze happens.
1.  Open a terminal (`Ctrl+Alt+T`).
2.  Run the following command to watch system logs in real-time:
    ```bash
    sudo journalctl -f
    ```
3.  Use your mouse until the freeze occurs.
4.  Check the terminal for messages containing `bluetooth`, `input`, `HID`, or `usb`.

**What to look for:** If you see errors about "bad report descriptor," "failed to parse," or similar, the next step is for you.

### Step 2: The Fix (Two Options)

#### Option A: The "Quick Config" (Power Management)
Often, the USB port controlling Bluetooth tries to save power and "sleeps" the mouse.
1.  Open **Blueman** (Bluetooth Manager) from your system tray.
2.  Go to **Settings** (or Adapter > Properties).
3.  **Disable** "Power Management" or "Bluetooth Power Saving."
4.  Alternatively, in terminal:
    ```bash
    # This disables auto-suspend for the Bluetooth USB controller
    echo 'options btusb enable_autosuspend=n' | sudo tee /etc/modprobe.d/btusb.conf
    sudo update-initramfs -u
    ```
    *Reboot after this.*

#### Option B: The "Kernel Driver" Fix (Advanced)
If the logs from Step 1 mention **HID report descriptor** issues, the mouse is sending a malformed data packet. A specific kernel module can intercept and correct this.

**Caveat:** This is for mice that send *wrong* data, not for signal interference. Check the logs first.

1.  **Prerequisites:**
    ```bash
    sudo apt install git build-essential dkms
    ```
2.  **Install the fix (Example for a specific mouse, but concept applies):**
    *Note: The search result shows a specific fix for a "Mi Silent Mouse" . If you have a different model, you may need to find a driver for it, but the process is the same.*
    ```bash
    git clone https://github.com/matega/hid_mimouse.git
    cd hid_mimouse
    make
    sudo make install
    sudo dkms add .
    sudo dkms install hid_mimouse/1.0
    ```
3.  Reboot.

### Step 3: The Nuclear Option (If above fails)
If power management didn't work and there is no specific driver for your mouse, you can disable **input-least** (a KDE feature that tries to guess which window you're clicking) which sometimes causes stutter:
1.  Open **System Settings**.
2.  Go to **Workspace Behavior** > **General Behavior**.
3.  Under "Clicking," disable **"Delay focus change until mouse stops moving"** or set "Active screen edges" to a higher delay.

**Which mouse model are you using?** If you tell me the brand/model, I can check if there is a specific HID fix driver available for it, as this is the most common culprit for "freezing but not disconnecting" issues on Kubuntu.