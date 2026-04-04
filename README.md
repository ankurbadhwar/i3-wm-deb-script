# 🚀 i3-wm Dotfiles

A fully reproducible, minimal, and highly modular **i3-based Linux desktop environment**. 

This repository is designed to give you a beautiful, themed (Catppuccin Mocha), and functional desktop environment practically out-of-the-box on a bare install of Debian, Ubuntu, or Arch Linux. 

---

## ✨ Features
- **Window Manager:** [i3](https://i3wm.org/) (Configured cleanly across 6 modular files)
- **Bar:** [Polybar](https://github.com/polybar/polybar) (Custom modules for Workspaces, Network, Battery, Audio, CPU, RAM)
- **Compositor:** [Picom](https://github.com/yshui/picom) (Hardware-accelerated GLX, shadows, screen tear protection, and transparency)
- **Launcher:** [Rofi](https://github.com/davatorium/rofi) (Configured for Apps, Windows, and Power Menu)
- **Terminal:** [Alacritty](https://github.com/alacritty/alacritty) (GPU-accelerated, themed)
- **Notifications:** [Dunst](https://dunst-project.org/) (Includes progress bars for volume and brightness overlay)
- **Display Manager:** LightDM (With `lightdm-gtk-greeter` customized)
- **GTK Theme:** Adwaita-dark with Papirus-Dark Icons (Included config for deep dark mode)
- **Aesthetics:** [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) system-wide color palette
- **Typography:** JetBrainsMono Nerd Font

---

## 🐧 Supported Distributions
The custom-built `install.sh` automatically detects your package manager and pulls the required dependencies.
- **Debian / Ubuntu / Pop!_OS** (`apt`) 
- **Arch Linux / EndeavourOS** (`pacman` / `AUR`)

---

## 🛠️ Installation 

1. **Clone the repository** to your local machine:
   ```bash
   git clone https://github.com/your-username/i3-wm-deb-script.git
   cd i3-wm-deb-script
   ```

2. **Run the installer:** 
   *(This will require `sudo` privileges to install packages, build `i3lock-color`, configure LightDM, and symlink configurations to `~/.config/`).*
   ```bash
   bash install.sh
   ```

3. **Reboot** to initialize your new LightDM display manager and login to your `i3` session!
   ```bash
   reboot
   ```

---

## ⌨️ Keybindings Checklist
> The Mod key is set to **Super/Windows** (`$mod`).

### 🪟 Windows & Workspaces
| Action | Keybinding |
| :--- | :--- |
| Move Focus | `$mod` + `Left/Right/Up/Down` |
| Move Window | `$mod` + `Shift` + `Left/Right/Up/Down` |
| Switch Workspace | `$mod` + `[1-0]` |
| Move to Workspace | `$mod` + `Shift` + `[1-0]` |
| Toggle Fullscreen | `$mod` + `f` |
| Drag Floating Window | Hold `$mod` and Left Click & Drag |
| Close Window | `$mod` + `q` |

### 🚀 Launchers & Utils
| Action | Keybinding |
| :--- | :--- |
| Terminal (Alacritty) | `$mod` + `Enter` |
| Fallback Terminal | `$mod` + `Shift` + `Enter` |
| File Manager (Thunar) | `$mod` + `e` |
| App Launcher (Rofi) | `$mod` + `d` |
| Take Screenshot (Flameshot) | `PrintScreen` |
| Reload i3 Config | `$mod` + `Shift` + `c` |
| Restart i3 (In-Place) | `$mod` + `Shift` + `r` |

### 💻 System & Hardware
| Action | Keybinding |
| :--- | :--- |
| Lock Screen | `$mod` + `l` |
| Power Menu | `$mod` + `Shift` + `e` |
| Volume Up/Down/Mute | `Multimedia Volume Keys` |
| Brightness Up/Down | `Multimedia Brightness Keys` |
| Play/Pause/Next/Prev | `Multimedia Audio Keys` |
| Mute Microphone | `Multimedia Mic Mute Key` |

---

## 📁 File Structure & Customization
Config files are split to be highly modular and debuggable. You can find them all within the cloned repository directory, which is symlinked to `~/.config/`.

```text
├── i3/                 # Central logic hub
│   ├── config          # Connects all modules & sets Mod key
│   ├── appearance.conf # Gaps, Borders, and visual spacing
│   ├── keybindings.conf# Mapping of all shortcut keys
│   ├── rules.conf      # Floating window specifications
│   ├── workspaces.conf # Assignment config for multi-monitors
│   └── scripts/        # Auto-starts, volume, brightness, and power scripts
├── themes/             # Color Palette & Typography
├── polybar/            # Status bar architecture
├── rofi/               # Launchers and dialog UI
├── dunst/              # Notification Engine properties
├── picom/              # Desktop compositing (blur, fade, tear-free)
├── gtk-2.0 & gtk-3.0/  # GUI Application dark mode overrides
├── wallpapers/         # Background image resources
└── install.sh          # One-click system setup script
```
