#!/usr/bin/env bash
# =============================================================================
# autostart.sh — One-time startup script for i3
# =============================================================================
# This runs ONCE when i3 first starts (not on reload/restart).
# Use for:
#   - Setting wallpaper
#   - Starting daemons that shouldn't be restarted on reload
#   - System tray applets
# =============================================================================

set -euo pipefail

WALLPAPER_DIR="$HOME/.config/wallpapers"

# --- Wallpaper ---
# Try multiple paths/formats, fall back to solid Catppuccin Mocha background
set_wallpaper() {
    if command -v feh &>/dev/null; then
        # Try specific filenames first
        for file in "wallpaper.jpg" "wallpaper.png" "wallpaper.webp"; do
            if [ -f "$WALLPAPER_DIR/$file" ]; then
                feh --bg-fill "$WALLPAPER_DIR/$file"
                return
            fi
        done

        # Try any image in the directory
        local first_image
        first_image=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \
            \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' \) \
            2>/dev/null | head -1)

        if [ -n "$first_image" ]; then
            feh --bg-fill "$first_image"
            return
        fi
    fi

    # Fallback: solid Catppuccin Mocha base color
    if command -v xsetroot &>/dev/null; then
        xsetroot -solid "#1e1e2e"
    fi
}
set_wallpaper

# --- Polkit Agent (for GUI password prompts) ---
# Try common polkit agents across distros
if command -v /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &>/dev/null; then
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
elif command -v /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &>/dev/null; then
    /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
elif command -v lxpolkit &>/dev/null; then
    lxpolkit &
fi

# --- System Tray Applets (optional) ---
# Network Manager applet
if command -v nm-applet &>/dev/null; then
    nm-applet &
fi

# Bluetooth
if command -v blueman-applet &>/dev/null; then
    blueman-applet &
fi

# Clipboard manager
if command -v clipit &>/dev/null; then
    clipit &
elif command -v parcellite &>/dev/null; then
    parcellite &
fi

# Flameshot (screenshot tool — needs to be running for Print key binding)
if command -v flameshot &>/dev/null; then
    flameshot &
fi

# --- Set keyboard repeat rate ---
xset r rate 300 50 2>/dev/null || true

echo "[autostart.sh] Startup complete."
