#!/bin/bash

echo "=== Verification after reboot ==="

# Check horizontal scroller with Solaar
echo "1. Checking Solaar status:"
pgrep -a solaar && echo "✅ Solaar running" || echo "⚠️ Solaar not running"

# Check Input Remapper
echo ""
echo "2. Checking Input Remapper:"
systemctl is-active input-remapper-daemon && echo "✅ Service active" || echo "⚠️ Service not active"

# Check for zombie
echo ""
echo "3. Checking for zombie processes:"
ps aux | grep -E "defunct.*input-remapper" | grep -v grep || echo "✅ No zombies"

# Check Bluetooth connection stability
echo ""
echo "4. Mouse connection info:"
dmesg | grep "MX Master" | tail -3

echo ""
echo "5. Test horizontal scroller in Zoom Screen"
echo "If it works, the fix is successful."