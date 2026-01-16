#!/usr/bin/env bash

THEME_NAME="Material-Black-Blueberry"
CURSOR_NAME="macOS"
THEME_FILE="$HOME/suckless/assets/Material-Black-Blueberry-2.9.9-07.tar"
BOOT_ZIP="$HOME/suckless/assets/linux-penguin.zip"
CURSOR_FILE="$HOME/suckless/assets/macOS.tar.xz"
ASSET_LOGO="$HOME/suckless/assets/ubuntu-logo.png"
SYSTEM_LOGO="/usr/share/plymouth/ubuntu-logo.png"

echo "Starting setup..."


echo "Installing nsxiv (Minimal Image Viewer)..."

sudo apt update
sudo apt install -y nsxiv


xdg-mime default nsxiv.desktop image/jpeg
xdg-mime default nsxiv.desktop image/png
xdg-mime default nsxiv.desktop image/gif

echo "✔ nsxiv installed and set as default image viewer."


mkdir -p "$HOME/.config/dunst" "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0" "$HOME/.themes" "$HOME/.icons"
sudo apt install -y plymouth plymouth-themes libpam-systemd gtk2-engines-murrine gtk2-engines-pixbuf unzip xdg-desktop-portal-gtk x11-xserver-utils imagemagick

# Extract Assets
[ -f "$HOME/suckless/dunst/dunstrc2" ] && cp -f "$HOME/suckless/dunst/dunstrc2" "$HOME/.config/dunst/dunstrc"


if ! command -v i3lock-color >/dev/null 2>&1; then
    echo "Installing build dependencies for i3lock-color..."

    sudo apt install -y autoconf gcc make pkg-config libpam0g-dev libcairo2-dev libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev libxcb-util0-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev libgif-dev

    TEMP_DIR=$(mktemp -d)
    git clone https://github.com/Raymo111/i3lock-color.git "$TEMP_DIR"
    cd "$TEMP_DIR"
    ./install-i3lock-color.sh
    echo "✔ i3lock-color manually built and linked."
fi

echo "Installing Betterlockscreen"
echo "Source: https://github.com/betterlockscreen/betterlockscreen"

BL_INSTALLER="$HOME/suckless/assets/betterlockscreen_install.sh"
FIXED_WALL="$HOME/suckless/assets/penguin-lock.jpg"
if [ -f "$BL_INSTALLER" ]; then
    chmod +x "$BL_INSTALLER"
    sudo "$BL_INSTALLER" system latest true
    echo "✔ Betterlockscreen setup complete."

    if [ -f "$FIXED_WALL" ]; then
    echo "Caching fixed wallpaper for Betterlockscreen..."
    betterlockscreen -u "$FIXED_WALL" --fx blur
    echo "✔ Wallpaper cached."
    else
        echo "Warning: Fixed wallpaper not found at $FIXED_WALL"
    fi
else
    echo "Error: $BL_INSTALLER not found!"
fi

if [ -f "$THEME_FILE" ]; then
    echo "Extracting Theme and Icons..."
    tar -xf "$THEME_FILE" -C "$HOME/.themes/"
    tar -xf "$THEME_FILE" -C "$HOME/.icons/"
fi

if [ -f "$CURSOR_FILE" ]; then
    echo "Extracting Cursor system-wide (Fix for Browser/Snaps)..."
    sudo mkdir -p /usr/share/icons
    sudo tar -xf "$CURSOR_FILE" -C /usr/share/icons/
fi

echo "Writing GTK and X11 configurations..."

cat <<EOF > "$HOME/.config/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name=$THEME_NAME
gtk-icon-theme-name=$THEME_NAME
gtk-cursor-theme-name=$CURSOR_NAME
gtk-cursor-theme-size=24
gtk-font-name=JetBrainsMono Nerd Font 10
gtk-application-prefer-dark-theme=1
EOF

cp "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"

# Set cursor in Xresources
echo "Xcursor.theme: $CURSOR_NAME" > "$HOME/.Xresources"
echo "Xcursor.size: 24" >> "$HOME/.Xresources"

if [ -d "$HOME/.themes/$THEME_NAME" ]; then
    ln -sf "$HOME/.themes/$THEME_NAME/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
    ln -sf "$HOME/.themes/$THEME_NAME/gtk-4.0/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css"
    ln -sf "$HOME/.themes/$THEME_NAME/gtk-4.0/assets" "$HOME/.config/gtk-4.0/assets"
fi

gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME"
gsettings set org.gnome.desktop.interface icon-theme "$THEME_NAME"
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_NAME"
gsettings set org.gnome.desktop.interface cursor-size 24
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

mkdir -p "$HOME/.config/xdg-desktop-portal"
cat <<EOF > "$HOME/.config/xdg-desktop-portal/portals.conf"
[preferred]
default=gtk
EOF

sudo chmod -R 755 /usr/share/icons/$CURSOR_NAME

if [ -f "$ASSET_LOGO" ]; then
    echo "Replacing Ubuntu logo with linux penguin logo..."
    
    if [ -f "$SYSTEM_LOGO" ] && [ ! -f "$SYSTEM_LOGO.back" ]; then
        sudo mv "$SYSTEM_LOGO" "$SYSTEM_LOGO.back"
    fi

    sudo cp "$ASSET_LOGO" "$SYSTEM_LOGO"
    echo "✔ Ubuntu logo replaced successfully."
else
    echo "⚠ Warning: $ASSET_LOGO not found. Skipping logo replacement."
fi

# Boot Splash
if [ -f "$BOOT_ZIP" ]; then
    sudo unzip -o "$BOOT_ZIP" -d /usr/share/plymouth/themes/
    sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/linux-penguin/linux-penguin.plymouth 200
    sudo update-alternatives --set default.plymouth /usr/share/plymouth/themes/linux-penguin/linux-penguin.plymouth
    if [ -d "/usr/share/plymouth/themes/linux-penguin" ]; then
        sudo sed -i 's/UseFirmwareBackground=true/UseFirmwareBackground=false/' /usr/share/plymouth/themes/linux-penguin/linux-penguin.plymouth
    fi
    sudo update-initramfs -u    
fi

echo "Setup complete!"