# Fedora Auto-Setup

Automated setup script for fresh Fedora (KDE Plasma) installations. Install packages, configure repositories, manage dotfiles, and apply system settings in one command.

## Quick Start

**One-liner install** (clones to `~/fedora-setup` and runs setup):

```bash
sh <(curl -L https://raw.githubusercontent.com/bgmulinari/fedora-setup/master/auto-install.sh)
```

**Manual install:**

```bash
git clone https://github.com/bgmulinari/fedora-setup.git
cd fedora-setup
sudo ./setup.sh
```

## Features

- **Progress TUI** - Visual split-view interface showing module progress and status
- **Modular design** - Enable/disable components as needed
- **Idempotent** - Safe to run multiple times
- **Selective execution** - Run only specific modules with `--only` or `--skip`
- **GNU Stow dotfiles** - Industry-standard symlink management
- **Logged output** - All actions saved to `setup.log`

## Directory Structure

```
fedora-setup/
├── auto-install.sh          # Remote bootstrap (curl | sh)
├── setup.sh                 # Main entry point
├── lib/
│   └── tui.sh               # TUI library (progress display)
├── packages/
│   ├── dnf-packages.txt     # DNF packages to install
│   ├── flatpaks.txt         # Flatpak apps to install
│   └── copr-repos.txt       # COPR repositories to enable
├── dotfiles/                # Stow-managed dotfiles
│   ├── bash/                # Bash configs (.bashrc.d/)
│   ├── btop/                # btop system monitor config
│   ├── claude/              # Claude Code settings
│   ├── ghostty/             # Ghostty terminal config
│   └── vscode/              # VS Code settings
├── config/
│   ├── dnf.conf             # DNF performance settings
│   ├── services.txt         # Systemd services to manage
│   └── kde-settings.sh      # KDE Plasma customizations
└── scripts/                 # Module scripts
    ├── repos.sh             # Repository setup (RPM Fusion, Flathub, COPR)
    ├── multimedia.sh        # Video codecs and hardware acceleration
    ├── packages.sh          # DNF package installation
    ├── flatpaks.sh          # Flatpak installation
    ├── dotnet.sh            # .NET SDK installation
    ├── jetbrains.sh         # JetBrains Toolbox installation
    ├── claude.sh            # Claude Code CLI installation
    ├── docker.sh            # Docker Engine installation
    ├── fonts.sh             # JetBrainsMono Nerd Font and Microsoft fonts
    ├── catppuccin.sh        # Catppuccin theme installation
    ├── dotfiles.sh          # GNU Stow dotfiles
    ├── kde.sh               # KDE configuration
    └── services.sh          # Systemd service management
```

## Usage

```bash
sudo ./setup.sh                       # Run full setup (with TUI)
sudo ./setup.sh -y                    # Skip confirmation prompt
sudo ./setup.sh --no-tui              # Run with plain text output
sudo ./setup.sh --only repos,packages # Run specific modules
sudo ./setup.sh --skip kde,services   # Skip specific modules
```

### Available Modules

| Module | Description |
|--------|-------------|
| `repos` | Enable RPM Fusion, Flathub, COPR repos, VS Code repo |
| `multimedia` | Install video codecs (ffmpeg, GStreamer) and hardware acceleration |
| `packages` | Install DNF packages from `packages/dnf-packages.txt` |
| `flatpaks` | Install Flatpak apps from `packages/flatpaks.txt` |
| `dotnet` | Install .NET SDK to `~/.dotnet` |
| `jetbrains` | Install JetBrains Toolbox App |
| `claude` | Install Claude Code CLI |
| `docker` | Install Docker Engine, add user to docker group |
| `fonts` | Install JetBrainsMono Nerd Font and Microsoft core fonts |
| `catppuccin` | Install Catppuccin Mocha theme (KDE, GTK, VS Code, btop) |
| `dotfiles` | Symlink dotfiles using GNU Stow |
| `kde` | Apply KDE Plasma settings (Catppuccin theme) |
| `services` | Enable/disable systemd services |

## Configuration

### DNF Packages

Edit `packages/dnf-packages.txt`:

```bash
# One package per line
code
gh
fastfetch

# Package groups use @ prefix
@development-tools
```

### Flatpak Apps

Edit `packages/flatpaks.txt`:

```bash
com.spotify.Client
com.discordapp.Discord
```

Find app IDs at [Flathub](https://flathub.org).

### COPR Repositories

Edit `packages/copr-repos.txt`:

```bash
scottames/ghostty
atim/lazygit
```

### Systemd Services

Edit `config/services.txt`:

```bash
sshd                  # Enable and start
cups:disable          # Disable
ModemManager:mask     # Mask
```

### KDE Plasma Settings

Edit `config/kde-settings.sh`:

```bash
# Global theme (Catppuccin Mocha Blue)
run_lookandfeel "Catppuccin-Mocha-Blue"

# GTK theme for GTK apps
run_kwrite --file gtk-3.0/settings.ini --group Settings --key gtk-theme-name "catppuccin-mocha-blue-standard+default"

# Fixed-width font
run_kwrite --file kdeglobals --group General --key fixed "JetBrainsMono Nerd Font,10"

# Default terminal
run_kwrite --file kdeglobals --group General --key TerminalApplication "ghostty"
```

### Dotfiles (GNU Stow)

Each subdirectory in `dotfiles/` mirrors your home directory:

```
dotfiles/bash/.bashrc.d/dotnet           →  ~/.bashrc.d/dotnet
dotfiles/ghostty/.config/ghostty/config  →  ~/.config/ghostty/config
dotfiles/vscode/.config/Code/User/...    →  ~/.config/Code/User/...
```

## Troubleshooting

```bash
cat setup.log                         # View logs
sudo ./setup.sh --only packages       # Re-run specific module
stow -d dotfiles -t ~ --adopt bash    # Resolve stow conflicts
```

## Requirements

- Fedora 39+ (KDE Plasma)
- Internet connection
- Root/sudo access
