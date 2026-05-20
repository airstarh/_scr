Certainly. Here is the technical task prompt based on our entire conversation:

---

## Technical Task: Bluetooth Mouse Freeze Diagnosis on KDE Plasma/Wayland

### Problem Description
Logitech MX Master 2S Bluetooth mouse experiences intermittent freezes lasting 10-15 seconds on Kubuntu 26 with KDE Plasma 6.6 running on Wayland. Freezes occur unpredictably, sometimes frequently (every 2-30 seconds), sometimes not at all for extended periods.

### System Environment
- **OS:** Kubuntu 26
- **DE:** KDE Plasma 6.6
- **Display Server:** Wayland (Xwayland present)
- **Kernel:** 7.0.0-15-generic
- **Bluetooth Hardware:** Realtek Bluetooth Radio (ID 0bda:8771)
- **Mouse:** Logitech MX Master 2S (HID++ 4.5)
- **Additional Software:** Input Remapper (virtual device mapping)
- **Power Management:** USB power/control set to "on" (autosuspend disabled)

### Observed Behavior from Logs
- Mouse reconnects frequently (multiple times within minutes)
- Each freeze likely corresponds to Bluetooth reconnection event
- Bluetooth service remains active (no crashes)
- USB power management not the cause (already disabled)
- Input Remapper creates virtual input devices but likely not root cause

### Requirements

**1. Diagnostic Script (Read-Only)**
- Must run with sudo (to read dmesg)
- Must work on Wayland (cannot rely on xinput)
- Must output to stdout for redirection: `sudo bash script.sh > log.txt`
- Must capture on freeze detection, not continuously
- Must stop with Ctrl+C
- No system modifications, no deletions, no power management changes

**2. Detection Mechanism**
- Must detect mouse unresponsiveness without xinput
- Option: xdotool getmouselocation with timeout
- Option: libinput debug-events timeout

**3. Data to Capture on Freeze**
- Kernel messages (dmesg tail 50-100 lines)
- Bluetooth service status (systemctl status bluetooth)
- USB devices (lsusb)
- Bluetooth device info (bluetoothctl info)
- USB power management settings (read-only)

**4. Constraints**
- User is blind - relies on screen reader and custom input mappings
- No commands that could break existing functionality
- No deletions or permanent changes
- Physical fixes preferred over software changes

### Previously Tried (Ineffective)
- USB autosuspend disable (already disabled)
- xinput-based detection (fails on Wayland)

### Suspected Root Causes (Hypotheses)
1. Mouse battery/power saving causing disconnects
2. 2.4GHz WiFi interference with Bluetooth
3. Realtek Bluetooth driver instability on kernel 7.0.0
4. Physical USB port issues (USB 3.0 interference)

### Out of Scope
- Permanent fixes (diagnosis only)
- X11 solutions (user confirmed on Wayland)
- Modifying Input Remapper configuration

### Deliverable Expected
Working diagnostic bash script that runs in background, detects mouse freezes on Wayland, captures relevant logs, and exits cleanly with Ctrl+C. User will run as `sudo bash script.sh > log.txt` and share output for analysis.

---

This prompt can be used to request a solution from another AI or developer.