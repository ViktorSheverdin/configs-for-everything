#!/bin/bash
# fix-displaylink-dock-usb.sh
#
# BUG: External keyboard/mouse don't work through DisplayLink dock on Arch Linux
#
# Root cause: The Genesys Logic GL3523 USB hubs inside the dock have separate
# USB 3.0 and USB 2.0 controllers. Keyboards/mice are USB 2.0 devices and need
# the USB 2.0 companion hubs. Linux power management (autosuspend) puts these
# hubs to sleep and they never wake up, so USB 2.0 peripherals are invisible.
# The monitors work because DisplayLink uses USB 3.0.
#
# Affected hardware:
#   - Intel Alpine Ridge Thunderbolt 3 (JHL6340) controller
#   - Genesys Logic GL3523/GL3526 hubs (common in DisplayLink docks)
#
# Prerequisites: displaylink, evdi-dkms, thunderbolt kernel module

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run as root: sudo $0"
    exit 1
fi

# Ensure thunderbolt module loads at boot
echo "Setting up thunderbolt module..."
modprobe thunderbolt
echo "thunderbolt" > /etc/modules-load.d/thunderbolt.conf

# Create udev rules to disable autosuspend for dock USB hubs
echo "Installing udev rules..."
cat > /etc/udev/rules.d/50-usb-dock.rules << 'RULES'
# Disable autosuspend for Genesys Logic hubs (DisplayLink dock)
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="05e3", ATTR{idProduct}=="0620", ATTR{power/autosuspend_delay_ms}="-1"
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="05e3", ATTR{idProduct}=="0626", ATTR{power/autosuspend_delay_ms}="-1"

# Disable autosuspend for Alpine Ridge xHCI controller
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x15db", ATTR{power/control}="on"
RULES

udevadm control --reload-rules

# Apply immediately to current session
echo "Applying to current session..."
for bus in /sys/bus/usb/devices/usb{3,4}/power/control; do
    [ -f "$bus" ] && echo "on" > "$bus"
done
for dev in /sys/bus/usb/devices/*/idVendor; do
    dir=$(dirname "$dev")
    if [ "$(cat "$dev" 2>/dev/null)" = "05e3" ]; then
        echo "-1" > "$dir/power/autosuspend_delay_ms" 2>/dev/null || true
    fi
done

echo ""
echo "Done. Unplug and replug the dock USB-C cable now."
echo ""
echo "--- TROUBLESHOOTING ---"
echo "If peripherals still don't work after replug:"
echo ""
echo "1. Check USB 2.0 hubs appear:  lsusb | grep 05e3"
echo "   You should see GL3523 (0620) AND GL3526 (0626) hubs."
echo ""
echo "2. Reset the xHCI controller:"
echo "   echo 0000:3d:00.0 | sudo tee /sys/bus/pci/drivers/xhci_hcd/unbind"
echo "   sleep 2"
echo "   echo 0000:3d:00.0 | sudo tee /sys/bus/pci/drivers/xhci_hcd/bind"
echo ""
echo "3. After sleep/resume the controller may fail (D3hot->D0 error)."
echo "   Run the xHCI reset above, or just replug the dock cable."
echo ""
echo "4. Verify thunderbolt module:  lsmod | grep ^thunderbolt"
echo "5. Check dmesg for errors:     journalctl -b -g 'xhci.*error|usb.*fail'"
