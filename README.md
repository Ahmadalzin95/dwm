# My Suckless Setup (dwm & dmenu)

This repository contains my personal configuration for dwm (dynamic window manager) and dmenu.
It is optimized for Ubuntu/Debian systems.

## Structure
- **dwm/**: The window manager with applied patches (autostart, fullgaps, restartsig).
- **dmenu/**: The dynamic menu for launching programs.
- **scripts/**: Essential system scripts.

## Applied Patches

### dwm
The following patches have been applied to the source code:
- [autostart](https://dwm.suckless.org/patches/autostart/): Enables a startup script (`~/.dwm/autostart.sh`) to run background processes.
- [fullgaps](https://dwm.suckless.org/patches/fullgaps/): Adds customizable gaps between windows for better aesthetics.
- [restartsig](https://dwm.suckless.org/patches/restartsig/): Allows restarting dwm without logging out (Keybinding: `Alr + Ctrl + Shift + q`).


### dmenu
- *Stock version (currently no patches applied)*

## Installation on a new system

1. **Install dependencies (Ubuntu/Debian):**
   ```bash
   sudo apt install build-essential libx11-dev libxinerama-dev libxft-dev git feh
   ```
2. **Clone the repository:**
   ```bash
   git clone git@github.com:Ahmadalzin95/my-suckless-config.git ~/suckless
   ```

3. **Install dwm::**
   ```bash
   cd ~/suckless/dwm
   sudo make clean install
   ```
   This command will install:
   * The dwm binary.
   * The dwm-start wrapper script (installed to /usr/local/bin/).
   * The dwm.desktop entry (installed to /usr/share/xsessions/).
4. **Install dependencies (Ubuntu/Debian):**
   ```bash
   sudo apt install build-essential libx11-dev libxinerama-dev libxft-dev git
   ```
5. **Install dependencies (Ubuntu/Debian):**
   ```bash
   # Create autostart directory
   mkdir -p ~/.dwm
   
   # Link autostart script
   ln -s ~/suckless/scripts/autostart.sh ~/.dwm/autostart.sh
   chmod +x ~/suckless/scripts/autostart.sh
   
   # Make monitor script executable
   chmod +x ~/suckless/scripts/monitor.sh
   ```

## Monitor Configuration (monitor.sh)
The script `scripts/monitor.sh` handles screen layout and resolution. It was generated using **Arandr**.

* If your monitor setup changes: Install `arandr`, configure the layout, save it, and copy the content into `scripts/monitor.sh`.

## Usage (Custom Keys)
* **Terminal:** `Alt + Shift + Enter`
* **Dmenu:** `Alt + p`
* **Restart (without logging out):** `Alt + Ctrl + Shift + q`