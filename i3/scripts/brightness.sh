#!/usr/bin/env bash
# =============================================================================
# brightness.sh — Screen brightness control with dunst notification
# =============================================================================
# Usage: brightness.sh up | down
# Dependencies: brightnessctl, dunstify (dunst), awk
#
# Called by keybindings.conf:
#   XF86MonBrightnessUp   → brightness.sh up
#   XF86MonBrightnessDown → brightness.sh down
# =============================================================================

set -euo pipefail

# --- Config ---
STEP=5            # percent per key press
MIN_BRIGHTNESS=1  # never go below 1% (avoid black screen)
NOTIFY_ID=2594    # fixed ID so dunst replaces rather than stacks

# --- Helpers ---
get_brightness() {
    brightnessctl -m | awk -F, '{ gsub(/%/,"",$4); print $4 }'
}

send_notification() {
    local bright="$1"
    local icon

    if [ "$bright" -lt 30 ]; then
        icon="display-brightness-low-symbolic"
    elif [ "$bright" -lt 70 ]; then
        icon="display-brightness-medium-symbolic"
    else
        icon="display-brightness-high-symbolic"
    fi

    dunstify -a "brightness" \
             -u low \
             -r "$NOTIFY_ID" \
             -i "$icon" \
             -h "int:value:${bright}" \
             "Brightness: ${bright}%"
}

# --- Actions ---
case "${1:-}" in
    up)
        brightnessctl set "+${STEP}%"
        send_notification "$(get_brightness)"
        ;;
    down)
        current=$(get_brightness)
        if [ "$current" -le "$MIN_BRIGHTNESS" ]; then
            # Already at minimum — don't go lower
            send_notification "$current"
            exit 0
        fi

        brightnessctl set "${STEP}%-"

        # Clamp: if we went below minimum, set to minimum
        new=$(get_brightness)
        if [ "$new" -lt "$MIN_BRIGHTNESS" ]; then
            brightnessctl set "${MIN_BRIGHTNESS}%"
        fi

        send_notification "$(get_brightness)"
        ;;
    *)
        echo "Usage: brightness.sh {up|down}" >&2
        exit 1
        ;;
esac
