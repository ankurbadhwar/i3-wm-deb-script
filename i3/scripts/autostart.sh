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

# --- Wallpaper ---
# feh is the simplest cross-distro wallpaper setter
if command -v feh &>/dev/null; then
    feh --bg-fill ~/.config/wallpapers/wallpaper.jpg 2>/dev/null || true
fi

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

# --- Set keyboard repeat rate ---
xset r rate 300 50 2>/dev/null || true

echo "[autostart.sh] Startup complete."
