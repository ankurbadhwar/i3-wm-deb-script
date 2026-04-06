# Roadmap

This is a living snapshot of the project — what’s already working, what still needs fixing, and where things are headed next.

If you're using or contributing to this setup, this section should give you a clear idea of its current state without digging through commits.

---

## What’s Already Working

Here’s everything that’s been implemented and is stable (or at least stable enough to use daily):

### Core Configuration
- Modular i3 config split cleanly into:
  - appearance
  - keybindings
  - window rules
  - workspaces
  - autostart  
  → Makes it easy to tweak one part without breaking everything else.

### Theming & Visuals
- Catppuccin Mocha theme system:
  - `themes/colors-dark.conf`
  - `fonts.conf`
- GTK theming:
  - GTK2 + GTK3 configured with **Adwaita-dark + Papirus-Dark**
- Alacritty:
  - Catppuccin colors
  - JetBrains Nerd Font
  - Transparency enabled

### Status Bar & UI
- Polybar setup includes:
  - Workspaces
  - Date/time
  - Audio
  - Battery
  - CPU / Memory
  - Network
  - System tray

### App Launcher (Rofi)
- Clean Catppuccin-styled launcher (`$mod + Space`)
- Fuzzy search + icons enabled
- Layout synced with config:
  - ~600px width
  - Centered
  - Prompt removed for minimal look

### Notifications (Dunst)
- Themed with Catppuccin urgency levels
- Progress bars supported (used in volume/brightness scripts)

### Compositor (Picom)
- GLX backend
- Shadows, fading, and rounded corners enabled

### Lock Screen
- `i3lock-color` bound to `$mod + l`

### System Integration
- LightDM + GTK greeter configured
- Wallpaper applied system-wide (including greeter)

### Utility Scripts
- Volume control:
  - Uses `pactl`
  - Shows Dunst progress notification
- Brightness control:
  - Uses `brightnessctl`
  - Same notification system

### Autostart
- Handles:
  - Wallpaper
  - Polkit agent
  - Tray applets
  - Keyboard repeat rate

### Installer
- Supports:
  - Debian / Ubuntu
  - Arch
- Features:
  - Idempotent symlinks (safe to re-run)
  - Font download automation
  - Installs `nm-applet` and `blueman`
  - Enables NetworkManager + Bluetooth services

---

## Known Issues (Next Up)

These are real problems — not theoretical ones. Fixing these will improve stability a lot.

- **Incorrect Dunst flag**
  - `dunst -config` → should be `dunst --config`
  - Current issue: custom theme is silently ignored

- **Overly strict autostart script**
  - `set -euo pipefail` causes full failure if *any* command breaks  
  - Example: missing polkit path stops everything else from launching

- **Install script directory leak**
  - `cd` is not wrapped in a subshell during i3lock-color build
  - If build fails → script stays in `/tmp` → breaks later steps

- **LightDM font issue**
  - Fonts installed to `~/.local/share/fonts/`
  - LightDM (system user) can’t access them  
  - Fix: move to `/usr/local/share/fonts/`

---

## What’s Being Worked On

### Phase 1 — Reliability (High Priority)

- Add fallback startup:
  - `~/.xinitrc` with `exec i3`
  - Useful when LightDM fails

- Clipboard manager:
  - Considering `parcellite` or `greenclip`
  - Will be added to install + autostart

- Smarter Picom backend:
  - Detect VM using `systemd-detect-virt`
  - Switch:
    - `glx` → `xrender` automatically when needed

---

### Phase 2 — Hardware Awareness

- Polybar battery module:
  - Disable automatically on desktops (no `/sys/class/power_supply/BAT*`)

- Network module fallback:
  - Add wired (Ethernet) support for non-WiFi setups

---

### Phase 3 — Theme Toggle System

Goal: switch between dark/light without touching configs manually.

Planned script:  
`i3/scripts/theme_toggle.sh`

It should:
- Toggle:
  - `colors-dark.conf` ↔ `colors-light.conf`
- Restart:
  - Polybar
  - Dunst
- Update:
  - Alacritty colors
- Reload:
  - i3 config

Extras:
- Keybinding: `$mod + Shift + t`
- Note: light theme already exists, but currently unused

---

### Phase 4 — General Polish

- Replace placeholder GitHub URL in README
- Add `xprop` tip in `rules.conf` comments for WM_CLASS discovery
- Document Nerd Font requirement (for icons in power menu)

---

## Ideas / Backlog

These are not committed yet — just things worth exploring later:

- Multi-monitor support:
  - Workspace → output mapping

- Rofi-based system menus:
  - WiFi (via `nmcli`)
  - Bluetooth (via `bluetoothctl`)
  - Could replace tray applets entirely

- Picom per-app opacity:
  - Example: Alacritty, Thunar

- Scratchpad terminal binding

- Quick browser launcher (`$mod + b`)

---

## Final Note

This setup is already very usable, but the focus now is:
1. **Reliability**
2. **Hardware adaptability**
3. **Quality-of-life improvements**
4. **Tweaks to my preferences**

If you're cloning this — expect things to work, but also expect a few rough edges (for now).