#!/usr/bin/env bash

# Arch Linux Installation Script - LUKS + btrfs + KDE Plasma
# WARNING: This script will ERASE ALL DATA on the target disk!

set -e  # Exit on error

# ============================================================================
# Configuration Variables - MODIFY THESE BEFORE RUNNING
# ============================================================================

DISK="/dev/nvme0n1"              # Target disk (e.g., /dev/sda, /dev/nvme0n1)
HOSTNAME="arch"            # System hostname
USERNAME="viktor"              # Username to create
TIMEZONE="America/Vancouver"     # Timezone (see /usr/share/zoneinfo/)
LOCALE="en_US.UTF-8"            # System locale
KEYMAP="us"                      # Console keymap

# Add after the configuration variables
cleanup_on_error() {
    echo "Cleaning up..."
    umount -R /mnt 2>/dev/null || true
    cryptsetup close cryptroot 2>/dev/null || true
}

trap cleanup_on_error ERR


# ============================================================================
# Installation Options
# ============================================================================

echo ""
echo "Installation Options:"
echo "1) Install Arch Linux with KDE Plasma only"
echo "2) Install Arch Linux with KDE Plasma + default apps"
echo ""
read -p "Choose an option (1 or 2): " INSTALL_OPTION

# ============================================================================
# Safety Check
# ============================================================================

echo "==========================================="
echo "Arch Linux Installation Script"
echo "==========================================="
echo ""
echo "WARNING: This will ERASE ALL DATA on $DISK"
echo ""
echo "Current configuration:"
echo "  Disk: $DISK"
echo "  Hostname: $HOSTNAME"
echo "  Username: $USERNAME"
echo "  Timezone: $TIMEZONE"
echo ""
lsblk
echo ""
read -p "Press Enter to continue or Ctrl+C to abort..."

# ============================================================================
# Partition the disk using sfdisk
# ============================================================================

echo ""
echo "Partitioning disk $DISK..."

sfdisk "$DISK" << EOF
label: gpt
size=512M, type=uefi
size=1G, type=linux
type=linux
EOF

echo "Partitioning complete!"

# Give kernel time to update partition table
sleep 2
partprobe "$DISK"

# ============================================================================
# Format EFI and boot partitions
# ============================================================================

echo ""
echo "Formatting partitions..."

mkfs.fat -F32 "${DISK}p1" 2>/dev/null || mkfs.fat -F32 "${DISK}1"
mkfs.ext4 "${DISK}p2" 2>/dev/null || mkfs.ext4 "${DISK}2"

# Determine partition naming scheme
if [[ -e "${DISK}p1" ]]; then
    EFI_PART="${DISK}p1"
    BOOT_PART="${DISK}p2"
    ROOT_PART="${DISK}p3"
else
    EFI_PART="${DISK}1"
    BOOT_PART="${DISK}2"
    ROOT_PART="${DISK}3"
fi

# ============================================================================
# Setup LUKS encryption
# ============================================================================

echo ""
echo "Setting up LUKS encryption on $ROOT_PART..."
echo "You will be prompted to enter a passphrase for disk encryption."

# Wipe partition signatures
wipefs -af "$ROOT_PART"

# Format with LUKS interactively
cryptsetup luksFormat "$ROOT_PART"

cryptsetup open "$ROOT_PART" cryptroot

# ============================================================================
# Create btrfs filesystem and subvolumes
# ============================================================================
# Verify cryptroot is open
if [[ ! -e /dev/mapper/cryptroot ]]; then
    echo "ERROR: Failed to open LUKS container"
    exit 1
fi
echo ""
echo "Creating btrfs filesystem and subvolumes..."

mkfs.btrfs -f /dev/mapper/cryptroot

# Mount to create subvolumes
mount /dev/mapper/cryptroot /mnt

# Create subvolumes
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots

# Unmount
umount /mnt

# ============================================================================
# Mount filesystems
# ============================================================================

echo ""
echo "Mounting filesystems..."

# Mount root subvolume
mount -o subvol=@ /dev/mapper/cryptroot /mnt

# Create mount points for home and snapshots
mkdir -p /mnt/home
mkdir -p /mnt/.snapshots
mkdir -p /mnt/boot

# Mount home subvolume
mount -o subvol=@home /dev/mapper/cryptroot /mnt/home

# Mount snapshots subvolume
mount -o subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots

# Mount boot partition
mount "$BOOT_PART" /mnt/boot

# NOW create the efi directory (after boot is mounted)
mkdir -p /mnt/boot/efi

# Mount EFI partition
mount "$EFI_PART" /mnt/boot/efi


# ============================================================================
# Load kernel module
# ============================================================================

modprobe dm_mod

# ============================================================================
# Install base system
# ============================================================================

echo ""
echo "Installing base system..."

# This will install some packages to "bootstrap" methaphorically our system. Feel free to add the ones you want
# "base, linux, linux-firmware" are needed. If you want a more stable kernel, then swap linux with linux-lts
# "base-devel" base development packages
# "git" to install the git vcs
# "btrfs-progs" are user-space utilities for file system management ( needed to harness the potential of btrfs )
# "grub" the bootloader
# "efibootmgr" needed to install grub
# "grub-btrfs" adds btrfs support for the grub bootloader and enables the user to directly boot from snapshots
# "inotify-tools" used by grub btrfsd deamon to automatically spot new snapshots and update grub entries
# "timeshift" a GUI app to easily create,plan and restore snapshots using BTRFS capabilities
# "amd-ucode" microcode updates for the cpu. If you have an intel one use "intel-ucode"
# "vim" my goto editor, if unfamiliar use nano
# "networkmanager" to manage Internet connections both wired and wireless ( it also has an applet package network-manager-applet )
# "pipewire pipewire-alsa pipewire-pulse pipewire-jack" for the new audio framework replacing pulse and jack. 
# "wireplumber" the pipewire session manager.
# "reflector" to manage mirrors for pacman
# "zsh" my favourite shell
# "zsh-completions" for zsh additional completions
# "zsh-autosuggestions" very useful, it helps writing commands [ Needs configuration in .zshrc ]
# "openssh" to use ssh and manage keys
# "man" for manual pages
# "sudo" to run commands as other users
pacstrap -K /mnt base base-devel linux linux-firmware git btrfs-progs grub efibootmgr grub-btrfs inotify-tools timeshift vim networkmanager pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber reflector zsh zsh-completions zsh-autosuggestions openssh man sudo

echo ""
# ============================================================================
# Generate fstab
# ============================================================================

echo ""
echo "Generating fstab..."

genfstab -U -p /mnt >> /mnt/etc/fstab

# ============================================================================
# Configure system (chroot part 1)
# ============================================================================

echo ""
echo "Configuring system..."

arch-chroot /mnt << CHROOT

# Set timezone
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

# Set locale
echo "$LOCALE UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf

# Set console keymap
touch /etc/vconsole.conf
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

# Set hostname
echo "$HOSTNAME" > /etc/hostname


# Configure mkinitcpio for encryption and btrfs
sed -i 's/^MODULES=.*/MODULES=(btrfs)/' /etc/mkinitcpio.conf
sed -i 's/^HOOKS=.*/HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)/' /etc/mkinitcpio.conf

# Generate initramfs
mkinitcpio -P

# Get UUID of encrypted partition
UUID=\$(blkid -s UUID -o value $ROOT_PART)

# Update GRUB configuration
sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet rd.luks.name=\${UUID}=cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@\"|" /etc/default/grub

# Install GRUB to EFI partition
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB


# Generate GRUB config
grub-mkconfig -o /boot/grub/grub.cfg

# Install display server
pacman -S --noconfirm xorg

# Install desktop environment
pacman -S --noconfirm plasma sddm

# Install system utilities
pacman -S --noconfirm sudo cronie

# Install Nvidia drivers if NVIDIA GPU is detected
if lspci | grep -i nvidia; then
    pacman -S --noconfirm nvidia nvidia-utils
fi

# Enable display manager and NetworkManager
systemctl enable sddm
systemctl enable NetworkManager

# Create user (using bash as default shell - switch to zsh later with 'chsh -s /bin/zsh')
useradd -m -G wheel -s /bin/bash $USERNAME

# Enable wheel group in sudoers - create directory first
mkdir -p /etc/sudoers.d
chmod 750 /etc/sudoers.d
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel


# Configure Timeshift for automatic snapshots
mkdir -p /etc/timeshift
cat > /etc/timeshift/timeshift.json << 'TIMESHIFT_EOF'
{
  "backup_device_uuid" : "",
  "parent_device_uuid" : "",
  "do_first_run" : "false",
  "btrfs_mode" : "true",
  "include_btrfs_home_for_backup" : "true",
  "include_btrfs_home_for_restore" : "true",
  "stop_cron_emails" : "true",
  "btrfs_use_qgroup" : "true",
  "schedule_monthly" : "false",
  "schedule_weekly" : "false",
  "schedule_daily" : "true",
  "schedule_hourly" : "false",
  "schedule_boot" : "false",
  "count_monthly" : "0",
  "count_weekly" : "0",
  "count_daily" : "7",
  "count_hourly" : "0",
  "count_boot" : "0",
  "snapshot_size" : "0",
  "snapshot_count" : "0",
  "date_format" : "%Y-%m-%d %H:%M:%S",
  "exclude" : [],
  "exclude-apps" : []
}
TIMESHIFT_EOF

# Enable services for snapshots
systemctl enable cronie.service
systemctl enable grub-btrfsd.service



# Verify home directory ownership
chown -R $USERNAME:$USERNAME /home/$USERNAME


# ============================================================================
# Install default apps if selected (MOVE THIS INSIDE THE CHROOT)
# ============================================================================

if [[ "$INSTALL_OPTION" == "2" ]]; then
    echo ""
    echo "Installing default applications..."
    echo ""
    
    curl -L https://raw.githubusercontent.com/ViktorSheverdin/configs-for-everything/main/default-apps.sh -o /tmp/default-apps.sh
    chmod +x /tmp/default-apps.sh
    bash /tmp/default-apps.sh
    
    echo ""
    echo "Default applications installed!"
fi




CHROOT

# ============================================================================
# Set passwords
# ============================================================================

# ============================================================================
# Set passwords (OUTSIDE the heredoc, using /dev/tty for input)
# ============================================================================

echo ""
echo "Setting root password..."
arch-chroot /mnt passwd < /dev/tty

echo ""
echo "Setting password for user $USERNAME..."
arch-chroot /mnt passwd "$USERNAME" < /dev/tty

# Verify home directory ownership
arch-chroot /mnt chown -R $USERNAME:$USERNAME /home/$USERNAME



# ============================================================================
# Installation complete
# ============================================================================

echo ""
echo "==========================================="
echo "Installation complete!"
echo "==========================================="
echo ""
echo "To finalize:"
echo "  1. Exit this script"
echo "  2. Run: umount -R /mnt"
echo "  3. Run: reboot"
echo ""
echo "After reboot:"
echo "  - You'll be prompted for your LUKS passphrase"
echo "  - Login with username: $USERNAME"
echo "  - Run: sudo pacman -Syu"
echo ""
