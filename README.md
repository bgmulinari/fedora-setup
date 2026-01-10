# Fedora Auto-Setup

Automated setup script for fresh Fedora (KDE Plasma) installations. Install packages, configure repositories, manage dotfiles, and apply system settings in one command.

## Quick Start

```bash
git clone https://github.com/YOUR_USERNAME/fedora-setup.git
cd fedora-setup

# Customize package lists, then run:
sudo ./setup.sh
```

## Features

- **Modular design** - Enable/disable components as needed
- **Idempotent** - Safe to run multiple times
- **Selective execution** - Run only specific modules with `--only` or `--skip`
- **GNU Stow dotfiles** - Industry-standard symlink management
- **Logged output** - All actions saved to `setup.log`

## Directory Structure

```
fedora-setup/
├── setup.sh                 # Main entry point
├── packages/
│   ├── dnf-packages.txt     # DNF packages to install
│   ├── flatpaks.txt         # Flatpak apps to install
│   └── copr-repos.txt       # COPR repositories to enable
├── dotfiles/                # Stow-managed dotfiles
│   ├── bash/                # Bash configs (.bashrc.d/)
│   ├── claude/              # Claude Code settings
│   └── konsole/             # Konsole terminal profiles
├── config/
│   ├── dnf.conf             # DNF performance settings
│   ├── services.txt         # Systemd services to manage
│   └── kde-settings.sh      # KDE Plasma customizations
└── scripts/                 # Module scripts
    ├── repos.sh             # Repository setup (RPM Fusion, Flathub, COPR)
    ├── packages.sh          # DNF package installation
    ├── flatpaks.sh          # Flatpak installation
    ├── dotnet.sh            # .NET SDK installation
    ├── jetbrains.sh         # JetBrains Toolbox installation
    ├── claude.sh            # Claude Code CLI installation
    ├── docker.sh            # Docker Engine installation
    ├── fonts.sh             # JetBrainsMono Nerd Font installation
    ├── dotfiles.sh          # GNU Stow dotfiles
    ├── kde.sh               # KDE configuration
    └── services.sh          # Systemd service management
```

## Usage

```bash
sudo ./setup.sh                       # Run full setup
sudo ./setup.sh --only repos,packages # Run specific modules
sudo ./setup.sh --skip kde,services   # Skip specific modules
```

### Available Modules

| Module | Description |
|--------|-------------|
| `repos` | Enable RPM Fusion, Flathub, COPR repos, VS Code repo |
| `packages` | Install DNF packages from `packages/dnf-packages.txt` |
| `flatpaks` | Install Flatpak apps from `packages/flatpaks.txt` |
| `dotnet` | Install .NET SDK to `~/.dotnet` |
| `jetbrains` | Install JetBrains Toolbox App |
| `claude` | Install Claude Code CLI |
| `docker` | Install Docker Engine, add user to docker group |
| `fonts` | Install JetBrainsMono Nerd Font |
| `dotfiles` | Symlink dotfiles using GNU Stow |
| `kde` | Apply KDE Plasma settings |
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
# Global theme
run_lookandfeel "org.fedoraproject.fedoradark.desktop"

# Fixed-width font
run_kwrite --file kdeglobals --group General --key fixed "JetBrainsMono Nerd Font,10"

# Default terminal
run_kwrite --file kdeglobals --group General --key TerminalApplication "ghostty"
```

### Dotfiles (GNU Stow)

Each subdirectory in `dotfiles/` mirrors your home directory:

```
dotfiles/bash/.bashrc.d/dotnet  →  ~/.bashrc.d/dotnet
dotfiles/claude/.claude.json    →  ~/.claude.json
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
