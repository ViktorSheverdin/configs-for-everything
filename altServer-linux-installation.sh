# Prerequisites
# A Linux computer (Ubuntu/Debian/Arch/Fedora etc.)
# Your iPhone and a USB cable
# A free Apple ID (your standard one works fine)
# libimobiledevice installed on your system

yay -S altserver-linux-bin
sudo pacman -S libimobiledevice usbmuxd
# (Note: You might need to check the exact binary name, sometimes it is just AltServer or altserver).
AltServer -u your_udid -a your_apple_id -p your_password
# Step 3: Pair Your iPhone
# Connect your iPhone to your PC via USB.
# Unlock your iPhone and tap "Trust" if prompted.
idevicepair pair
# Step 4: Install AltStore
./AltServer-x86_64 -u your_udid -a your_apple_id -p your_password

# Use an App-Specific Password: If you have Two-Factor Authentication (2FA) enabled 
# your normal password might not work. 
# Go to appleid.apple.com -> Sign & Security -> App-Specific Passwords -> 
# Generate one and use that instead.

# Step 5: Start Sideloading
# Once AltStore is on your phone:

# On iPhone: Go to Settings -> General -> VPN & Device Management, tap your email, and Trust it.
# Open AltStore on your phone.
# Download the uYouEnhanced .ipa (as described in the previous guide) on your phone.
# In AltStore, tap the + icon and select the .ipa file.

# (Optional) Wi-Fi Refreshing
# To refresh apps without a cable, you need to set up netmuxd, 
# but simpler is to just plug in your phone once a week 
# and run the AltServer command again to refresh, 
# or keep the server running in the background while plugged in.
