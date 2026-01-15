#!/usr/bin/env bash

# Default Applications Installation Script
# This script installs commonly used applications via AUR

set -e  # Exit on error

# Get the username (passed as argument or use current user)
USERNAME="${1:-$SUDO_USER}"
if [ -z "$USERNAME" ]; then
    USERNAME="viktor"  # Fallback to viktor if can't determine
fi

echo "==========================================="
echo "Installing Default Applications"
echo "==========================================="
echo "Installing for user: $USERNAME"
echo ""

# ============================================================================
# Install yay (AUR helper)
# ============================================================================

# Check if yay is already installed
if command -v yay &> /dev/null; then
    echo "yay is already installed, skipping..."
    echo ""
else
    echo "Installing yay AUR helper..."

    # Install base-devel and git if not already installed (as root - OK)
    pacman -S --needed --noconfirm base-devel git

    # Install yay as the user (NOT root)
    sudo -u $USERNAME bash << 'EOFYAY'
    # Clean up any existing yay directory
    rm -rf /tmp/yay

    # Clone yay repository
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay

    # Build and install yay
    makepkg -si --noconfirm

    # Clean up
    cd ~
    rm -rf /tmp/yay
EOFYAY

    echo "yay installed successfully!"
    echo ""
fi

# ============================================================================
# Install applications
# ============================================================================

echo "Installing applications..."
echo ""

# Install git, GitHub CLI, and zsh from official repos (as root - OK)
echo "Installing git, GitHub CLI, and zsh..."
sudo pacman -S --noconfirm git github-cli zsh

# Install npm, yarn, pnpm, nodejs, python (as root - OK)
echo "Installing Node.js tools and Python..."
pacman -S --noconfirm npm yarn pnpm nodejs python


# Install Oh My Zsh as the user
if [ -d "/home/$USERNAME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed, skipping..."
else
    echo "Installing Oh My Zsh..."
    sudo -u $USERNAME bash << 'EOFOMZ'
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
EOFOMZ
fi

# Change default shell to zsh
echo "Changing default shell to zsh for $USERNAME..."
chsh -s /usr/bin/zsh $USERNAME

# Create Konsole profile directory and file as the user
sudo -u $USERNAME bash << 'EOFKONSOLE'
mkdir -p /home/$USERNAME/.local/share/konsole
cat > /home/$USERNAME/.local/share/konsole/viktor-zsh.profile << 'KONSOLE_EOF'
[General]
Command=/usr/bin/zsh
Name=viktor-zsh
Parent=FALLBACK/
KONSOLE_EOF
EOFKONSOLE


# Install AUR packages as the user
echo "Installing Google Chrome..."
sudo -u $USERNAME yay -S --noconfirm google-chrome

echo "Installing Visual Studio Code..."
sudo -u $USERNAME yay -S --noconfirm visual-studio-code-bin

echo "Installing Claude Code..."
sudo -u $USERNAME curl -fsSL https://claude.ai/install.sh | bash

# Configure Claude Code PATH in user's shell configs
sudo -u $USERNAME bash << 'EOFPATH'
if ! grep -q '.local/bin' ~/.zshrc 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
fi
if ! grep -q '.local/bin' ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi
EOFPATH

echo "Installing Discord..."
sudo -u $USERNAME yay -S --noconfirm discord

echo "Installing Google Antigravity..."
sudo -u $USERNAME yay -S --noconfirm antigravity

echo "Installing Display Link drivers..."
sudo -u $USERNAME yay -S --noconfirm displaylink evdi-dkms

# Enable and start the displaylink service (as root - OK)
systemctl enable displaylink.service
systemctl start displaylink.service
echo ""
echo "Display Link drivers installed and service started. Service status:"
systemctl status displaylink.service --no-pager

echo "Installing btop system monitor..."
pacman -S --noconfirm btop

# Install openssh (as root - OK)
echo "Installing openssh..."
pacman -S --noconfirm openssh

# Setup SSH known_hosts as the user
sudo -u $USERNAME bash << 'EOFSSH'
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts
EOFSSH

# ============================================================================
# Installation complete
# ============================================================================

echo ""
echo "==========================================="
echo "Default Applications Installed!"
echo "==========================================="
echo "" 
echo "Installed applications:"
echo "  - git (version control)"
echo "  - GitHub CLI (gh)"
echo "  - zsh + Oh My Zsh (shell)"
echo "  - yay (AUR helper)"
echo "  - Google Chrome"
echo "  - Visual Studio Code"
echo "  - Claude Code (with PATH configured)"
echo "  - Discord"
echo "  - Google Antigravity"
echo "  - Display Link drivers"
echo "  - btop (system monitor)"
echo "  - Node.js, npm, yarn, pnpm"
echo "  - Python 3"
echo ""
echo "Note: Default shell has been changed to zsh for $USERNAME"
echo "      Claude Code is available in ~/.local/bin"
echo "      Log out and back in for shell changes to take effect"
echo ""
