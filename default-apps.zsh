#!/usr/bin/env zsh

# Default Applications Installation Script
# This script installs commonly used applications via AUR

set -e  # Exit on error

echo "==========================================="
echo "Installing Default Applications"
echo "==========================================="
echo ""

# ============================================================================
# Install yay (AUR helper)
# ============================================================================

echo "Installing yay AUR helper..."

# Install base-devel and git if not already installed
sudo pacman -S --needed --noconfirm base-devel git

# Clone yay repository
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay

# Build and install yay
makepkg -si --noconfirm

# Clean up
cd ~
rm -rf /tmp/yay

echo "yay installed successfully!"
echo ""

# ============================================================================
# Install applications via yay
# ============================================================================

echo "Installing applications..."
echo ""

# Update package databases
yay -Sy

# Install Google Chrome
echo "Installing Google Chrome..."
yay -S --noconfirm google-chrome

# Install Visual Studio Code
echo "Installing Visual Studio Code..."
yay -S --noconfirm visual-studio-code-bin

# Install Claude Code CLI
echo "Installing Claude Code..."
yay -S --noconfirm claude-code

# Install Discord
echo "Installing Discord..."
yay -S --noconfirm discord

# ============================================================================
# Installation complete
# ============================================================================

echo ""
echo "==========================================="
echo "Default Applications Installed!"
echo "==========================================="
echo ""
echo "Installed applications:"
echo "  - yay (AUR helper)"
echo "  - Google Chrome"
echo "  - Visual Studio Code"
echo "  - Claude Code"
echo "  - Discord"
echo ""
echo "You can now use these applications from your desktop environment."
echo ""
