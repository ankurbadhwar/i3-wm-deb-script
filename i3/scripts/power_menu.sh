#!/usr/bin/env bash
# =============================================================================
# power_menu.sh — Rofi-based power menu
# =============================================================================
# Usage: power_menu.sh
# Dependencies: rofi, systemctl, i3lock-color, i3-msg
#
# Called by keybindings.conf:
#   $mod+Shift+e → power_menu.sh
# =============================================================================

set -euo pipefail

# --- Menu options ---
lock="  Lock"
logout="  Logout"
suspend="  Suspend"
reboot="  Reboot"
shutdown="  Shutdown"

# --- Build menu (newline-separated for rofi) ---
options="${lock}\n${logout}\n${suspend}\n${reboot}\n${shutdown}"

# --- Show rofi prompt ---
chosen=$(echo -e "$options" \
    | rofi -dmenu \
           -p "Power" \
           -theme-str 'window {width: 250px;}' \
           -theme-str 'listview {lines: 5;}' \
    || true)

# --- Act on choice ---
case "$chosen" in
    "$lock")
        i3lock-color -c 1e1e2e
        ;;
    "$logout")
        i3-msg exit
        ;;
    "$suspend")
        i3lock-color -c 1e1e2e && systemctl suspend
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$shutdown")
        systemctl poweroff
        ;;
    *)
        # Escaped or empty — do nothing
        exit 0
        ;;
esac
