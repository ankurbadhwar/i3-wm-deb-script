#!/usr/bin/env bash

# =============================================================================
# Polybar Launch Script
# =============================================================================
# Kill any running Polybar instances, then launch the main bar.
# Called from i3 autostart.conf.
# =============================================================================

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch bar
polybar main 2>&1 | tee -a /tmp/polybar.log &

echo "Polybar launched."
