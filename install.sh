#!/usr/bin/env bash
# =============================================================================
# i3 Desktop Environment — Install Script
# =============================================================================
# Supported: Debian, Ubuntu, Arch, EndeavourOS (and derivatives)
#
# What this does:
#   1. Detects distro
#   2. Installs all required packages
#   3. Installs JetBrainsMono Nerd Font
#   4. Symlinks dotfiles to ~/.config/
#   5. Deploys LightDM config
#   6. Sets up GTK dark theme
#   7. Enables LightDM
#
# Usage: bash install.sh
# =============================================================================

set -e

# --- Logging ---
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

log_info() { echo -e "${GREEN}[INFO]${RESET} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
log_err()  { echo -e "${RED}[ERROR]${RESET} $1"; exit 1; }
log_step() { echo -e "${CYAN}[STEP]${RESET} $1"; }

# --- Paths ---
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
FONT_DIR="$HOME/.local/share/fonts"

# =============================================================================
# OS Detection
# =============================================================================
log_step "Detecting Operating System..."

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    LIKE=$ID_LIKE
    log_info "Detected: $PRETTY_NAME (ID=$OS, ID_LIKE=$LIKE)"
else
    log_err "Cannot detect OS. Only Debian, Ubuntu, and Arch based distros are supported."
fi

# =============================================================================
# Package Installation
# =============================================================================

# Common package list (names that are the same across distros)
COMMON_DESCRIPTION="i3, LightDM, Alacritty, Thunar, Rofi, Polybar, Picom, Dunst, PipeWire, Flameshot, feh, brightnessctl, playerctl"

install_debian_based() {
    log_step "Installing packages for Debian/Ubuntu..."
    sudo apt update

    log_info "Installing core packages: $COMMON_DESCRIPTION"
    sudo apt install -y --no-install-recommends \
        i3 \
        lightdm lightdm-gtk-greeter \
        alacritty thunar \
        rofi polybar picom dunst \
        pipewire pipewire-pulse wireplumber \
        flameshot feh brightnessctl playerctl \
        papirus-icon-theme \
        lxappearance \
        xss-lock xdg-user-dirs xterm \
        git curl wget build-essential

    # i3lock-color (not in standard repos — build from source)
    log_info "Checking for i3lock-color..."
    if ! command -v i3lock-color &> /dev/null; then
        log_info "Building i3lock-color from source..."
        sudo apt install -y autoconf gcc make pkg-config \
            libpam0g-dev libcairo2-dev libfontconfig1-dev \
            libxcb-composite0-dev libev-dev libx11-xcb-dev \
            libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev \
            libxcb-image0-dev libxcb-util0-dev libxcb-xrm-dev \
            libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev

        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"
        git clone https://github.com/Raymo111/i3lock-color.git
        cd i3lock-color
        ./install-i3lock-color.sh
        cd "$REPO_DIR"
        rm -rf "$TEMP_DIR"
        log_info "i3lock-color built successfully."
    else
        log_info "i3lock-color is already installed."
    fi
}

install_arch_based() {
    log_step "Installing packages for Arch/EndeavourOS..."

    log_info "Installing core packages: $COMMON_DESCRIPTION"
    sudo pacman -S --needed --noconfirm \
        i3-wm \
        lightdm lightdm-gtk-greeter \
        alacritty thunar \
        rofi polybar picom dunst \
        pipewire pipewire-pulse wireplumber \
        flameshot feh brightnessctl playerctl \
        papirus-icon-theme \
        lxappearance \
        xss-lock xdg-user-dirs xterm \
        git curl wget base-devel

    # i3lock-color from AUR
    log_info "Checking for i3lock-color..."
    if ! command -v i3lock-color &> /dev/null; then
        log_info "Installing i3lock-color from AUR..."
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"
        git clone https://aur.archlinux.org/i3lock-color.git
        cd i3lock-color
        makepkg -si --noconfirm
        cd "$REPO_DIR"
        rm -rf "$TEMP_DIR"
        log_info "i3lock-color installed successfully."
    else
        log_info "i3lock-color is already installed."
    fi
}

# Run the right installer
if [[ "$OS" == "debian" || "$OS" == "ubuntu" || "$LIKE" == *"debian"* || "$LIKE" == *"ubuntu"* ]]; then
    install_debian_based
elif [[ "$OS" == "arch" || "$OS" == "endeavouros" || "$LIKE" == *"arch"* ]]; then
    install_arch_based
else
    log_err "Unsupported OS: $OS ($LIKE). Only Debian, Ubuntu, and Arch based distros are supported."
fi

# =============================================================================
# Font Installation — JetBrainsMono Nerd Font
# =============================================================================
log_step "Checking for JetBrainsMono Nerd Font..."

if fc-list | grep -qi "JetBrainsMono Nerd Font" 2>/dev/null; then
    log_info "JetBrainsMono Nerd Font is already installed."
else
    log_info "Installing JetBrainsMono Nerd Font..."
    mkdir -p "$FONT_DIR"

    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
    FONT_TEMP=$(mktemp -d)

    if curl -fsSL "$FONT_URL" -o "$FONT_TEMP/JetBrainsMono.tar.xz"; then
        tar -xf "$FONT_TEMP/JetBrainsMono.tar.xz" -C "$FONT_TEMP"
        # Install only .ttf files (skip variable fonts to avoid conflicts)
        find "$FONT_TEMP" -name "*.ttf" ! -name "*Variable*" -exec cp {} "$FONT_DIR/" \;
        fc-cache -fv > /dev/null 2>&1
        log_info "JetBrainsMono Nerd Font installed successfully."
    else
        log_warn "Could not download font. Install manually from: https://www.nerdfonts.com/"
    fi

    rm -rf "$FONT_TEMP"
fi

# =============================================================================
# Dotfile Deployment — Symlinks
# =============================================================================
log_step "Setting up dotfile symlinks..."

mkdir -p "$CONFIG_DIR"

# Symlink each config directory
for app in i3 alacritty dunst picom polybar rofi themes wallpapers gtk-3.0 gtk-2.0; do
    if [ -d "$REPO_DIR/$app" ]; then
        TARGET="$CONFIG_DIR/$app"

        # If target is already a symlink pointing to us, skip
        if [ -L "$TARGET" ] && [ "$(readlink -f "$TARGET")" == "$REPO_DIR/$app" ]; then
            log_info "$app already symlinked correctly."
            continue
        fi

        # Back up existing (but not if it's a broken symlink)
        if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
            log_warn "Backing up existing $TARGET → ${TARGET}.bak"
            mv "$TARGET" "${TARGET}.bak"
        elif [ -L "$TARGET" ]; then
            # Remove stale symlink
            rm "$TARGET"
        fi

        ln -sfn "$REPO_DIR/$app" "$TARGET"
        log_info "Symlinked $app → $TARGET"
    fi
done

# Ensure scripts are executable
log_info "Making scripts executable..."
find "$REPO_DIR/i3/scripts" -type f -name "*.sh" -exec chmod +x {} \;
chmod +x "$REPO_DIR/polybar/launch.sh"

# Also ensure GTK2 can find its config by symlinking ~/.gtkrc-2.0
if [ -f "$REPO_DIR/gtk-2.0/.gtkrc-2.0" ]; then
    ln -sfn "$REPO_DIR/gtk-2.0/.gtkrc-2.0" "$HOME/.gtkrc-2.0"
fi

# Copy wallpaper to system directory for LightDM
log_info "Deploying LightDM wallpaper..."
sudo mkdir -p /usr/share/backgrounds
sudo cp "$REPO_DIR/wallpapers/wallpaper.png" /usr/share/backgrounds/i3-wallpaper.png

# =============================================================================
# GTK Dark Theme Setup
# =============================================================================
log_step "Configuring GTK dark theme..."

# Apply via gsettings if available (GNOME/GTK apps respect this)
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface font-name "JetBrainsMono Nerd Font 10" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" 2>/dev/null || true
    log_info "Applied dark theme via gsettings."
fi

# Create user dirs (~/Desktop, ~/Downloads, etc.)
xdg-user-dirs-update 2>/dev/null || true

# =============================================================================
# LightDM Configuration
# =============================================================================
log_step "Configuring LightDM..."

# Deploy lightdm.conf
if [ -f "$REPO_DIR/lightdm/lightdm.conf" ]; then
    log_info "Deploying LightDM config..."
    sudo cp "$REPO_DIR/lightdm/lightdm.conf" /etc/lightdm/lightdm.conf
fi

# Deploy greeter config
if [ -f "$REPO_DIR/lightdm/lightdm-gtk-greeter.conf" ]; then
    log_info "Deploying LightDM GTK Greeter config..."
    sudo cp "$REPO_DIR/lightdm/lightdm-gtk-greeter.conf" /etc/lightdm/lightdm-gtk-greeter.conf
fi

# Create i3.desktop session file if it doesn't exist (safety net)
if [ ! -f /usr/share/xsessions/i3.desktop ]; then
    log_info "Creating i3 session file..."
    sudo mkdir -p /usr/share/xsessions
    sudo tee /usr/share/xsessions/i3.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=i3
Comment=Improved dynamic tiling window manager
Exec=i3
TryExec=i3
Type=Application
X-LightDM-DesktopName=i3
DesktopNames=i3
EOF
fi

# Enable LightDM as the sole display manager
log_info "Enabling LightDM as the display manager..."

# Disable ALL competing display managers first (both distro families)
for dm in gdm gdm3 sddm lxdm xdm; do
    if systemctl is-enabled "$dm" &> /dev/null 2>&1; then
        log_warn "Disabling competing display manager: $dm"
        sudo systemctl disable "$dm" 2>/dev/null || true
        sudo systemctl stop "$dm" 2>/dev/null || true
    fi
done

# Enable LightDM
sudo systemctl enable lightdm

if [[ "$OS" == "debian" || "$OS" == "ubuntu" || "$LIKE" == *"debian"* || "$LIKE" == *"ubuntu"* ]]; then
    # Debian/Ubuntu: set the default-display-manager file (dpkg mechanism)
    echo "/usr/sbin/lightdm" | sudo tee /etc/X11/default-display-manager > /dev/null
    log_info "Set /etc/X11/default-display-manager → /usr/sbin/lightdm"

    # Also reconfigure via debconf if available (the most reliable method)
    if command -v dpkg-reconfigure &> /dev/null; then
        echo "lightdm shared/default-x-display-manager select lightdm" | sudo debconf-set-selections 2>/dev/null || true
        sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure lightdm 2>/dev/null || true
        log_info "Ran dpkg-reconfigure to register LightDM as default."
    fi
elif [[ "$OS" == "arch" || "$OS" == "endeavouros" || "$LIKE" == *"arch"* ]]; then
    # Arch: systemctl enable is sufficient, but verify
    log_info "LightDM enabled via systemctl (Arch)."
fi

# Verify
if systemctl is-enabled lightdm &> /dev/null 2>&1; then
    log_info "✓ LightDM is enabled and will start on boot."
else
    log_warn "LightDM may not be properly enabled. Run: sudo systemctl enable lightdm"
fi

# =============================================================================
# Done
# =============================================================================
echo ""
log_info "========================================="
log_info "  Installation complete!"
log_info "========================================="
log_info ""
log_info "  Dotfiles symlinked to: $CONFIG_DIR"
log_info "  Font installed to:     $FONT_DIR"
log_info "  LightDM enabled as display manager"
log_info ""
log_info "  Please reboot to start your i3 session."
log_info "========================================="
