#!/usr/bin/env bash

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

# Install git, GitHub CLI, and zsh from official repos
echo "Installing git, GitHub CLI, and zsh..."
sudo pacman -S --noconfirm git github-cli zsh

# Install Oh My Zsh
echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Change default shell to zsh
echo "Changing default shell to zsh..."
chsh -s /usr/bin/zsh

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

# Configure Claude Code PATH
echo "Configuring Claude Code PATH..."
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Install Discord
echo "Installing Discord..."
yay -S --noconfirm discord

# Install Google Antigravity
echo "Installing Google Antigravity..."
yay -S --noconfirm antigravity

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
echo ""
echo "Note: Your default shell has been changed to zsh."
echo "      Claude Code is available in ~/.local/bin"
echo ""
echo "You can now use these applications from your desktop environment."
echo ""
