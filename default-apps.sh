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

# Check if yay is already installed
if command -v yay &> /dev/null; then
    echo "yay is already installed, skipping..."
    echo ""
else
    echo "Installing yay AUR helper..."

    # Install base-devel and git if not already installed
    sudo pacman -S --needed --noconfirm base-devel git

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

    echo "yay installed successfully!"
    echo ""
fi

# ============================================================================
# Install applications via yay
# ============================================================================

echo "Installing applications..."
echo ""

# Install git, GitHub CLI, and zsh from official repos
echo "Installing git, GitHub CLI, and zsh..."
sudo pacman -S --noconfirm git github-cli zsh

# Install Oh My Zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed, skipping..."
else
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Change default shell to zsh
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo "Changing default shell to zsh..."
    chsh -s /usr/bin/zsh
else
    echo "Default shell is already zsh, skipping..."
fi

# Update Konsole to use zsh
cat >> ~/.local/share/konsole/viktor-zsh.profile << KONSOLE_EOF
[General]
Command=/usr/bin/zsh
Name=viktor-zsh
Parent=FALLBACK/
KONSOLE_EOF

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
if grep -q '.local/bin' ~/.zshrc 2>/dev/null; then
    echo "Claude Code PATH already configured, skipping..."
else
    echo "Configuring Claude Code PATH..."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
fi

echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc


# Install Discord
echo "Installing Discord..."
yay -S --noconfirm discord

# Install Google Antigravity
echo "Installing Google Antigravity..."
yay -S --noconfirm antigravity

# Install Display Link drivers
echo "Install Display Link drivers"
# Install drivers with evdi-dkms
yay -S displaylink evdi-dkms --noconfirm
# Enable and start the displaylink service
sudo systemctl enable displaylink.service
sudo systemctl start displaylink.service
echo ""
echo "Display Link drivers installed and service started. Service status:"
sudo systemctl status displaylink.service

# Install btop
echo "Installing btop system monitor..."
yay -S --noconfirm btop

# Install openssh
echo "Installing openssh..."
sudo pacman -S --noconfirm openssh
ssh-keyscan github.com >> ~/.ssh/known_hosts

# Install npm, yarn and pnpm
echo "Installing yarn and pnpm..."
sudo pacman -S npm --noconfirm
sudp pacman -S yarn --noconfirm
sudo pacman -S pnpm --noconfirm
sudo pacman -S nodejs --noconfirm

# Install KDE Plasma theme
# Colorful-Dark-Plasma
# https://www.pling.com/p/2091077
# https://github.com/L4ki/Colorful-Plasma-Themes

echo "Installing Colorful KDE Plasma Theme..."
sudo pacman -S qt5-base qt5-svg qt5-declarative qt5-quickcontrols --noconfirm
sudo sudo pacman -S kvantum --confirm
# Clone theme repository if not already present
if [ ! -d "/tmp/Colorful-Plasma-Themes" ]; then
    git clone https://github.com/L4ki/Colorful-Plasma-Themes.git /tmp/Colorful-Plasma-Themes
fi

THEME_SOURCE="/tmp/Colorful-Plasma-Themes"

# Create necessary directories
mkdir -p ~/.local/share/{plasma/desktoptheme,plasma/look-and-feel,color-schemes,icons,konsole,Kvantum,aurorae/themes,wallpapers}
mkdir -p ~/.themes

# Install theme components
echo "Installing Plasma theme components..."
cp -r "$THEME_SOURCE/Colorful Plasma Themes/Colorful-Dark-Plasma" ~/.local/share/plasma/desktoptheme/
cp -r "$THEME_SOURCE/Colorful Global Themes"/* ~/.local/share/plasma/look-and-feel/
cp "$THEME_SOURCE/Colorful Color Schemes"/*.colors ~/.local/share/color-schemes/
cp -r "$THEME_SOURCE/Colorful Icons Themes"/* ~/.local/share/icons/
cp -r "$THEME_SOURCE/Colorful GTK Themes" ~/.themes/Colorful-Dark-GTK
cp -r "$THEME_SOURCE/Colorful Kvantum Themes"/* ~/.local/share/Kvantum/
cp -r "$THEME_SOURCE/Colorful Window Decorations"/* ~/.local/share/aurorae/themes/
cp "$THEME_SOURCE/Colorful Konsole Color Schemes"/*.colorscheme ~/.local/share/konsole/ 2>/dev/null || true

# Install wallpapers (each in its own directory as per KDE convention)
echo "Installing wallpapers..."
for wallpaper in "$THEME_SOURCE/Colorful Wallpapers"/*.png; do
    if [ -f "$wallpaper" ]; then
        # Get filename without extension and path
        name=$(basename "$wallpaper" .png)
        # Create wallpaper directory with contents subdirectory
        mkdir -p ~/.local/share/wallpapers/"$name"/contents/images
        # Copy the wallpaper
        cp "$wallpaper" ~/.local/share/wallpapers/"$name"/contents/images/
        # Create a basic metadata.json for the wallpaper
        cat > ~/.local/share/wallpapers/"$name"/metadata.json << EOF
{
    "KPlugin": {
        "Id": "$name",
        "Name": "$name"
    }
}
EOF
    fi
done

# Install SDDM theme (requires sudo)
echo "Installing SDDM login theme..."
sudo mkdir -p /usr/share/sddm/themes/
sudo cp -r "$THEME_SOURCE/Colorful SDDM Themes"/* /usr/share/sddm/themes/

# Configure SDDM to use the Colorful theme
echo "Configuring SDDM to use Colorful-SDDM theme..."
sudo mkdir -p /etc/sddm.conf.d/
sudo tee /etc/sddm.conf.d/theme.conf > /dev/null << EOF
[Theme]
Current=Colorful-SDDM
EOF

# Apply the Global Theme
echo "Applying Colorful-Dark-Global-6 theme..."
lookandfeeltool -a Colorful-Dark-Global-6

# Configure lock screen to use the Global Theme
echo "Configuring lock screen theme..."
kwriteconfig6 --file kscreenlockerrc --group Greeter --key Theme "Colorful-Dark-Global-6"

# Enable Kvantum for transparency and blur effects
echo "Enabling Kvantum widget style..."
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle "kvantum"
mkdir -p ~/.config/Kvantum
cat > ~/.config/Kvantum/kvantum.kvconfig << KVCONFIG_EOF
[General]
theme=Colorful-Dark-Kvantum
KVCONFIG_EOF

# Enable KWin blur effects
echo "Enabling blur effects..."
kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled "true"
qdbus org.kde.KWin /KWin reconfigure 2>/dev/null

# Set wallpaper
echo "Setting wallpaper..."
plasma-apply-wallpaperimage ~/.local/share/wallpapers/Colorful-Circle\ Wallpaper\ Without\ Logo/contents/images/Colorful-Circle\ Wallpaper\ Without\ Logo.png

echo "Colorful theme installed successfully!"
echo ""
echo "✓ Desktop theme applied"
echo "✓ Lock screen configured"
echo "✓ Wallpaper set to: Colorful-Circle Wallpaper Without Logo"
echo "✓ Kvantum widget style enabled (for transparency)"
echo "✓ Blur effects enabled"
echo ""
echo "IMPORTANT - For full transparency/blur effects:"
echo "  Log out and log back in (recommended)"
echo "  Some transparency may appear immediately, but logout ensures everything works"
echo ""
echo "To see the SDDM login screen theme:"
echo "  You MUST log out or restart your system"
echo ""
echo "To test the lock screen theme:"
echo "  Press Meta+L or lock your screen from the menu"
echo ""
echo "Optional - Fine-tune theme components:"
echo "  Go to System Settings → Appearance"
echo ""
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
echo "  - Colorful KDE Plasma Theme"
echo ""
echo "Note: Your default shell has been changed to zsh."
echo "      Claude Code is available in ~/.local/bin"
echo ""
