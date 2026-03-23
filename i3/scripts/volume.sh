#!/usr/bin/env bash
# =============================================================================
# volume.sh — Volume control with dunst notification
# =============================================================================
# Usage: volume.sh up | down | mute
# Dependencies: pactl (PipeWire/PulseAudio), dunstify (dunst), awk
#
# Called by keybindings.conf:
#   XF86AudioRaiseVolume → volume.sh up
#   XF86AudioLowerVolume → volume.sh down
#   XF86AudioMute        → volume.sh mute
# =============================================================================

set -euo pipefail

# --- Config ---
STEP=5            # percent per key press
MAX_VOL=150       # hard cap (above 100 = boost)
NOTIFY_ID=2593    # fixed ID so dunst replaces rather than stacks
SINK="@DEFAULT_SINK@"

# --- Helpers ---
get_volume() {
    pactl get-sink-volume "$SINK" \
        | awk '/front-left:/ { gsub(/%/,"",$5); print $5 }'
}

is_muted() {
    pactl get-sink-mute "$SINK" | grep -q "yes"
}

send_notification() {
    local vol="$1"
    local icon

    if is_muted || [ "$vol" -eq 0 ]; then
        icon="audio-volume-muted"
    elif [ "$vol" -lt 30 ]; then
        icon="audio-volume-low"
    elif [ "$vol" -lt 70 ]; then
        icon="audio-volume-medium"
    else
        icon="audio-volume-high"
    fi

    dunstify -a "volume" \
             -u low \
             -r "$NOTIFY_ID" \
             -i "$icon" \
             -h "int:value:${vol}" \
             "Volume: ${vol}%"
}

# --- Actions ---
case "${1:-}" in
    up)
        # Unmute first if muted
        is_muted && pactl set-sink-mute "$SINK" 0

        current=$(get_volume)
        if [ "$current" -lt "$MAX_VOL" ]; then
            pactl set-sink-volume "$SINK" "+${STEP}%"
        fi
        send_notification "$(get_volume)"
        ;;
    down)
        # Unmute first if muted
        is_muted && pactl set-sink-mute "$SINK" 0

        pactl set-sink-volume "$SINK" "-${STEP}%"
        send_notification "$(get_volume)"
        ;;
    mute)
        pactl set-sink-mute "$SINK" toggle
        if is_muted; then
            dunstify -a "volume" \
                     -u low \
                     -r "$NOTIFY_ID" \
                     -i "audio-volume-muted" \
                     "Volume: Muted"
        else
            send_notification "$(get_volume)"
        fi
        ;;
    *)
        echo "Usage: volume.sh {up|down|mute}" >&2
        exit 1
        ;;
esac
