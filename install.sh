#!/usr/bin/env bash
# =============================================================================
# i3 Desktop Environment — Install Script
# =============================================================================
# Supported: Debian, Ubuntu (and derivatives)
#
# What this does:
#   1. Detects Debian/Ubuntu distro
#   2. Installs all required packages
#   3. Installs JetBrainsMono Nerd Font
#   4. Deploys dotfiles to ~/.config/ (symlink or copy)
#   5. Deploys LightDM config
#   6. Sets up GTK dark theme
#   7. Enables LightDM
#
# Usage: 
#   bash install.sh                  # Full install (symlinks configs)
#   bash install.sh --copy-configs   # Full install (copies configs instead of symlinking)
#   bash install.sh --export-packages# Export required packages for all distros
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

# --- Package Lists ---
COMMON_DESCRIPTION="i3, LightDM, Alacritty, Thunar, Rofi, Polybar, Picom, Dunst, PipeWire, Flameshot, feh, brightnessctl, playerctl"

DEBIAN_PACKAGES=(
    i3
    lightdm lightdm-gtk-greeter
    alacritty thunar
    rofi polybar picom dunst
    pipewire pipewire-pulse wireplumber
    flameshot feh brightnessctl playerctl
    papirus-icon-theme
    lxappearance
    network-manager-gnome blueman
    xss-lock xdg-user-dirs xterm
    xserver-xorg xinit
    git curl wget build-essential
)

BUILD_DEPS_I3LOCK_COLOR=(
    autoconf gcc make pkg-config
    libpam0g-dev libcairo2-dev libfontconfig1-dev
    libxcb-composite0-dev libev-dev libx11-xcb-dev
    libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev
    libxcb-image0-dev libxcb-util0-dev libxcb-xrm-dev
    libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev
)

show_help() {
    cat << 'EOF'
i3 Desktop Environment Installer (Debian)

Usage:
  bash install.sh [OPTIONS]

Options:
  --export-packages, -e   Export the list of packages required to install across distros and Debian
  --copy-configs, -c      Copy configuration files to ~/.config instead of symlinking
  --help, -h              Display this help message
EOF
    exit 0
}

export_packages() {
    echo "=================================================================="
    echo "  Package Requirements for i3 Desktop Environment Setup"
    echo "=================================================================="
    echo ""
    echo "Core components needed (generic package names):"
    echo "  - Window Manager:    i3 / i3-wm"
    echo "  - Display Manager:   lightdm, lightdm-gtk-greeter"
    echo "  - Terminal:          alacritty"
    echo "  - File Manager:      thunar"
    echo "  - App Launcher:      rofi"
    echo "  - Status Bar:        polybar"
    echo "  - Compositor:        picom"
    echo "  - Notifications:     dunst"
    echo "  - Audio Server:      pipewire, pipewire-pulse, wireplumber"
    echo "  - Utilities:         flameshot, feh, brightnessctl, playerctl"
    echo "  - Theming:           papirus-icon-theme, lxappearance"
    echo "  - Applets:           network-manager-applet / network-manager-gnome, blueman"
    echo "  - Session / X11:     xss-lock, xdg-user-dirs, xterm, xorg / xserver-xorg, xinit"
    echo "  - Lock Screen:       i3lock-color (build from source: https://github.com/Raymo111/i3lock-color)"
    echo ""
    echo "------------------------------------------------------------------"
    echo "Debian / Ubuntu apt install command:"
    echo "------------------------------------------------------------------"
    echo "sudo apt update && sudo apt install -y --no-install-recommends \\"
    for pkg in "${DEBIAN_PACKAGES[@]}"; do
        echo "    $pkg \\"
    done
    echo ""
    echo "Debian dependencies to build i3lock-color from source:"
    echo "sudo apt install -y \\"
    for pkg in "${BUILD_DEPS_I3LOCK_COLOR[@]}"; do
        echo "    $pkg \\"
    done
    echo ""
    echo "------------------------------------------------------------------"
    echo "Arch Linux (pacman) reference equivalent:"
    echo "------------------------------------------------------------------"
    echo "sudo pacman -S --needed i3-wm lightdm lightdm-gtk-greeter alacritty thunar \\"
    echo "    rofi polybar picom dunst pipewire pipewire-pulse wireplumber \\"
    echo "    flameshot feh brightnessctl playerctl papirus-icon-theme \\"
    echo "    lxappearance network-manager-applet blueman xss-lock xdg-user-dirs \\"
    echo "    xterm xorg xorg-xinit git curl wget base-devel"
    echo "# (i3lock-color available in AUR)"
    echo ""
    echo "------------------------------------------------------------------"
    echo "Fedora (dnf) reference equivalent:"
    echo "------------------------------------------------------------------"
    echo "sudo dnf install i3 lightdm lightdm-gtk alacritty thunar rofi polybar \\"
    echo "    picom dunst pipewire pipewire-pulseaudio wireplumber flameshot feh \\"
    echo "    brightnessctl playerctl papirus-icon-theme lxappearance \\"
    echo "    network-manager-applet blueman xss-lock xdg-user-dirs xterm \\"
    echo "    xorg-x11-server-Xorg xorg-x11-xinit git curl wget"
    echo "=================================================================="
}

USE_COPY=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --export-packages|-e)
            export_packages
            exit 0
            ;;
        --copy-configs|-c)
            USE_COPY=true
            shift
            ;;
        --help|-h)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
done

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
    log_err "Cannot detect OS. Only Debian and Ubuntu based distros are supported."
fi

# =============================================================================
# Package Installation
# =============================================================================

install_debian_based() {
    log_step "Installing packages for Debian..."
    sudo apt update

    log_info "Installing core packages: $COMMON_DESCRIPTION"
    sudo apt install -y --no-install-recommends "${DEBIAN_PACKAGES[@]}"

    # i3lock-color (not in standard repos — build from source)
    log_info "Checking for i3lock-color..."
    if ! command -v i3lock-color &> /dev/null; then
        log_info "Building i3lock-color from source..."
        sudo apt install -y "${BUILD_DEPS_I3LOCK_COLOR[@]}"

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

# Run Debian installer
if [[ "$OS" == "debian" || "$OS" == "ubuntu" || "$LIKE" == *"debian"* || "$LIKE" == *"ubuntu"* ]]; then
    install_debian_based
else
    log_err "Unsupported OS: $OS ($LIKE). This script only supports Debian-based distributions. Use --export-packages to view requirements for other distros."
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
# Dotfile Deployment
# =============================================================================
mkdir -p "$CONFIG_DIR"

if [ "$USE_COPY" = true ]; then
    log_step "Copying dotfiles to $CONFIG_DIR..."
else
    log_step "Setting up dotfile symlinks..."
fi

# Deploy each config directory
for app in i3 alacritty dunst picom polybar rofi themes wallpapers gtk-3.0 gtk-2.0; do
    if [ -d "$REPO_DIR/$app" ]; then
        TARGET="$CONFIG_DIR/$app"

        if [ "$USE_COPY" = true ]; then
            # Copy mode: back up existing directory or remove symlink
            if [ -L "$TARGET" ]; then
                rm "$TARGET"
            elif [ -d "$TARGET" ]; then
                log_warn "Backing up existing $TARGET → ${TARGET}.bak"
                mv "$TARGET" "${TARGET}.bak"
            fi
            cp -r "$REPO_DIR/$app" "$TARGET"
            log_info "Copied $app → $TARGET"
        else
            # Symlink mode
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
    fi
done

# Ensure scripts are executable
log_info "Making scripts executable..."
if [ "$USE_COPY" = true ] && [ -d "$CONFIG_DIR/i3/scripts" ]; then
    find "$CONFIG_DIR/i3/scripts" -type f -name "*.sh" -exec chmod +x {} \;
fi
if [ "$USE_COPY" = true ] && [ -f "$CONFIG_DIR/polybar/launch.sh" ]; then
    chmod +x "$CONFIG_DIR/polybar/launch.sh"
fi
find "$REPO_DIR/i3/scripts" -type f -name "*.sh" -exec chmod +x {} \;
chmod +x "$REPO_DIR/polybar/launch.sh"

# Also ensure GTK2 can find its config by ~/.gtkrc-2.0
if [ -f "$REPO_DIR/gtk-2.0/.gtkrc-2.0" ]; then
    if [ "$USE_COPY" = true ]; then
        if [ -L "$HOME/.gtkrc-2.0" ]; then
            rm "$HOME/.gtkrc-2.0"
        elif [ -f "$HOME/.gtkrc-2.0" ]; then
            mv "$HOME/.gtkrc-2.0" "$HOME/.gtkrc-2.0.bak"
        fi
        cp "$REPO_DIR/gtk-2.0/.gtkrc-2.0" "$HOME/.gtkrc-2.0"
        log_info "Copied .gtkrc-2.0 → $HOME/.gtkrc-2.0"
    else
        ln -sfn "$REPO_DIR/gtk-2.0/.gtkrc-2.0" "$HOME/.gtkrc-2.0"
        log_info "Symlinked .gtkrc-2.0 → $HOME/.gtkrc-2.0"
    fi
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

# Wipe existing symlink in case systemd gets hung up, then forcefully enable
sudo rm -f /etc/systemd/system/display-manager.service 2>/dev/null || true
sudo systemctl enable --force lightdm

# Debian/Ubuntu: set the default-display-manager file (dpkg mechanism)
echo "/usr/sbin/lightdm" | sudo tee /etc/X11/default-display-manager > /dev/null
log_info "Set /etc/X11/default-display-manager → /usr/sbin/lightdm"

# Also reconfigure via debconf if available (the most reliable method)
if command -v dpkg-reconfigure &> /dev/null; then
    echo "lightdm shared/default-x-display-manager select lightdm" | sudo debconf-set-selections 2>/dev/null || true
    sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure lightdm 2>/dev/null || true
    log_info "Ran dpkg-reconfigure to register LightDM as default."
fi

# =============================================================================
# Enable Supporting Services
# =============================================================================
log_step "Enabling NetworkManager and Bluetooth services..."

# NetworkManager — required for nm-applet to actually manage connections
sudo systemctl enable NetworkManager 2>/dev/null && \
    log_info "✓ NetworkManager enabled." || \
    log_warn "Could not enable NetworkManager — enable manually: sudo systemctl enable NetworkManager"

# Bluetooth — required for blueman-applet to reach the bluetooth daemon
sudo systemctl enable bluetooth 2>/dev/null && \
    log_info "✓ Bluetooth service enabled." || \
    log_warn "Could not enable bluetooth — enable manually: sudo systemctl enable bluetooth"

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
if [ "$USE_COPY" = true ]; then
    log_info "  Dotfiles copied to:    $CONFIG_DIR"
else
    log_info "  Dotfiles symlinked to: $CONFIG_DIR"
fi
log_info "  Font installed to:     $FONT_DIR"
log_info "  LightDM enabled as display manager"
log_info ""
log_info "  Please reboot to start your i3 session."
log_info "========================================="
