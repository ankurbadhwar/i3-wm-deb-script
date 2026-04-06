# i3-wm Dotfiles

A clean, reproducible, and modular **i3-based Linux desktop setup** designed to turn a fresh install into a polished, fully usable environment with minimal effort.

This project exists because setting up a good i3 environment from scratch takes time. This gives you a solid, opinionated base that looks great (Catppuccin Mocha) and works immediately—while still being easy to customize.

---

## What You’re Getting

This setup is minimal without feeling bare, and modular without being confusing.

### Core Components

- **Window Manager:** [i3](https://i3wm.org/)  
  Split across multiple config files so you can actually understand and tweak it.

- **Bar:** [Polybar](https://github.com/polybar/polybar)  
  Comes with modules for:
  - Workspaces
  - Network
  - Battery
  - Audio
  - CPU / RAM

- **Compositor:** [Picom](https://github.com/yshui/picom)  
  - GLX backend (hardware accelerated)
  - Shadows and transparency
  - Tear-free rendering

- **Launcher:** [Rofi](https://github.com/davatorium/rofi)  
  - App launcher
  - Window switcher
  - Power menu

- **Terminal:** [Alacritty](https://github.com/alacritty/alacritty)  
  Fast, GPU-accelerated, and themed to match everything else.

- **Notifications:** [Dunst](https://dunst-project.org/)  
  Includes visual feedback like volume and brightness progress bars.

- **Display Manager:** LightDM  
  With a customized `lightdm-gtk-greeter` for a consistent login experience.

---

## Visuals & Theming

- **Color Scheme:** [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) (applied system-wide)
- **GTK Theme:** Adwaita-dark
- **Icons:** Papirus-Dark
- **Font:** JetBrainsMono Nerd Font

Everything is tuned to give you a cohesive dark experience across the entire system.

---

## Supported Distributions

The `install.sh` script automatically detects your system and installs everything you need.

- Debian / Ubuntu / Pop!_OS (`apt`)
- Arch Linux / EndeavourOS (`pacman` + AUR)

If you're on one of these, setup should be smooth.

---

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/i3-wm-deb-script.git
cd i3-wm-deb-script
```

### 2. Run the Installer

```bash
bash install.sh
```

This script will:
- Install all required packages
- Build and install `i3lock-color`
- Configure LightDM
- Symlink configs into `~/.config/`

> You’ll need `sudo` privileges here.

### 3. Reboot

```bash
reboot
```

After reboot:
- LightDM should appear
- Log into the **i3 session**
- Your full environment should load automatically

---

## Keybindings (Quick Reference)

The **Mod key = Super / Windows key (`$mod`)**

---

### Window & Workspace Management

| Action | Keybinding |
| :--- | :--- |
| Move Focus | `$mod` + Arrow Keys |
| Move Window | `$mod` + `Shift` + Arrow Keys |
| Switch Workspace | `$mod` + `[1-0]` |
| Move to Workspace | `$mod` + `Shift` + `[1-0]` |
| Toggle Fullscreen | `$mod` + `f` |
| Drag Floating Window | Hold `$mod` + Left Click |
| Close Window | `$mod` + `q` |

---

### Launchers & Tools

| Action | Keybinding |
| :--- | :--- |
| Terminal (Alacritty) | `$mod` + `Enter` |
| Fallback Terminal | `$mod` + `Shift` + `Enter` |
| File Manager (Thunar) | `$mod` + `e` |
| App Launcher (Rofi) | `$mod` + `d` |
| Screenshot (Flameshot) | `PrintScreen` |
| Reload i3 Config | `$mod` + `Shift` + `c` |
| Restart i3 | `$mod` + `Shift` + `r` |

---

### System Controls

| Action | Keybinding |
| :--- | :--- |
| Lock Screen | `$mod` + `l` |
| Power Menu | `$mod` + `Shift` + `e` |
| Volume Controls | Multimedia Keys |
| Brightness Controls | Multimedia Keys |
| Media Playback | Multimedia Keys |
| Mic Mute | Multimedia Key |

---

## Project Structure

Everything is intentionally modular so you don’t end up digging through a massive config file.

```text
├── i3/                 # Core window manager config
│   ├── config          # Entry point (loads everything else)
│   ├── appearance.conf # Gaps, borders, spacing
│   ├── keybindings.conf# All shortcuts
│   ├── rules.conf      # Floating window rules
│   ├── workspaces.conf # Multi-monitor setup
│   └── scripts/        # Autostart + system scripts
├── themes/             # Colors and fonts
├── polybar/            # Status bar config
├── rofi/               # Launcher + menus
├── dunst/              # Notifications
├── picom/              # Compositor settings
├── gtk-2.0 & gtk-3.0/  # GTK overrides (dark mode consistency)
├── wallpapers/         # Backgrounds
└── install.sh          # Setup script
```

---

## Customization Tips

- Change keybindings → `i3/keybindings.conf`
- Adjust gaps/borders → `i3/appearance.conf`
- Fix multi-monitor behavior → `i3/workspaces.conf`
- Modify bar → `polybar/`

Because everything is split cleanly, you can tweak one part without breaking the rest.

---

## Notes & Gotchas

- A **reboot is required** after installation (LightDM setup depends on it)
- If something doesn’t launch:
  - Check scripts in `i3/scripts/`
  - Verify dependencies installed correctly
- If fonts or icons look off:
  - Ensure JetBrainsMono Nerd Font and Papirus icons installed properly

---

## Who Is This For?

- You want a **ready-to-use i3 setup** without spending hours configuring
- You like **minimal but polished desktops**
- You still want **full control and easy customization**

---

## When Should You Use This?

- Fresh Linux install
- Moving from GNOME/KDE to i3
- You want a clean base to build your own setup on

---

If you end up heavily modifying this, that’s expected—that’s exactly what this setup is meant for.