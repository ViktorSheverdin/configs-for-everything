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

