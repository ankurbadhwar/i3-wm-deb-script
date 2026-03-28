#!/usr/bin/env bash

set -e

# Logging colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

log_info() { echo -e "${GREEN}[INFO]${RESET} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
log_err() { echo -e "${RED}[ERROR]${RESET} $1"; exit 1; }

# Paths
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

log_info "Detecting Operating System..."

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    LIKE=$ID_LIKE
else
    log_err "Cannot detect OS. Only Debian, Ubuntu, and Arch based distros are supported."
fi

install_debian_based() {
    log_info "Detected Debian/Ubuntu based system."
    log_info "Updating package lists..."
    sudo apt update

    log_info "Installing core packages..."
    sudo apt install -y i3 sddm alacritty thunar rofi polybar picom dunst pipewire pipewire-pulse flameshot git curl wget build-essential

    log_info "Checking for i3lock-color..."
    if ! command -v i3lock-color &> /dev/null; then
        log_info "Building i3lock-color from source..."
        sudo apt install -y autoconf gcc make pkg-config libpam0g-dev libcairo2-dev libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev libxcb-util0-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev
        
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
    log_info "Detected Arch based system."
    log_info "Installing core packages..."
    sudo pacman -S --needed --noconfirm i3-wm sddm alacritty thunar rofi polybar picom dunst pipewire pipewire-pulse flameshot git curl wget base-devel

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

# Run installation based on OS
if [[ "$OS" == "debian" || "$OS" == "ubuntu" || "$LIKE" == *"debian"* || "$LIKE" == *"ubuntu"* ]]; then
    install_debian_based
elif [[ "$OS" == "arch" || "$LIKE" == *"arch"* ]]; then
    install_arch_based
else
    log_err "Unsupported OS: $OS. Only Debian, Ubuntu, and Arch based distros are supported."
fi

# Setup Dotfiles
log_info "Setting up configurations..."

# Create config directories if they omit
mkdir -p "$CONFIG_DIR"

log_info "Symlinking/Copying dotfiles..."
for app in i3 alacritty dunst picom polybar rofi; do
    if [ -d "$REPO_DIR/$app" ]; then
        # Back up existing
        if [ -e "$CONFIG_DIR/$app" ]; then
            log_warn "Backing up existing $CONFIG_DIR/$app to ${app}.bak"
            mv "$CONFIG_DIR/$app" "$CONFIG_DIR/${app}.bak"
        fi
        cp -r "$REPO_DIR/$app" "$CONFIG_DIR/$app"
        log_info "Linked $app to $CONFIG_DIR"
    fi
done

# Ensure scripts are executable
log_info "Making scripts executable..."
find "$CONFIG_DIR/i3/scripts" -type f -name "*.sh" -exec chmod +x {} \;
if [ -d "$CONFIG_DIR/polybar/scripts" ]; then
    find "$CONFIG_DIR/polybar/scripts" -type f -name "*.sh" -exec chmod +x {} \;
fi

log_info "Installation complete! Please reboot or log out to start your new i3 session."
