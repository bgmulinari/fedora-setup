# Fedora Auto-Setup

Automated setup script for fresh Fedora (KDE Plasma) installations. Install all your packages, configure repositories, manage dotfiles, and apply system settings in one command.

## Quick Start

```bash
# Clone/download this repo to your new system
git clone https://github.com/YOUR_USERNAME/fedora-setup.git
cd fedora-setup

# 1. Customize your package lists (see Configuration below)
# 2. Add your dotfiles to the dotfiles/ directory
# 3. Run the setup
sudo ./setup.sh
```

## Features

- **Modular design** - Enable/disable components as needed
- **Idempotent** - Safe to run multiple times
- **Dry-run mode** - Preview changes before applying
- **Selective execution** - Run only specific modules
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
│   ├── bash/                # Example: bash configs
│   ├── git/                 # Example: git configs
│   └── nvim/                # Example: neovim configs
├── config/
│   ├── dnf.conf             # DNF performance settings
│   ├── services.txt         # Systemd services to enable
│   └── kde-settings.sh      # KDE Plasma customizations
└── scripts/                 # Module scripts (auto-executed)
    ├── repos.sh             # Repository setup
    ├── packages.sh          # DNF installation
    ├── flatpaks.sh          # Flatpak installation
    ├── dotnet.sh            # .NET SDK installation
    ├── jetbrains.sh         # JetBrains Toolbox installation
    ├── claude.sh            # Claude Code CLI installation
    ├── docker.sh            # Docker Engine installation
    ├── dotfiles.sh          # Stow dotfiles
    ├── kde.sh               # KDE configuration
    └── services.sh          # Service management
```

## Usage

### Full Setup

```bash
sudo ./setup.sh
```

### Dry Run (Preview Changes)

```bash
sudo ./setup.sh --dry-run
```

### Run Specific Modules Only

```bash
sudo ./setup.sh --only repos,packages
sudo ./setup.sh --only dotfiles,kde
```

### Skip Specific Modules

```bash
sudo ./setup.sh --skip flatpaks
sudo ./setup.sh --skip kde,services
```

### Available Modules

| Module | Description |
|--------|-------------|
| `repos` | Enable RPM Fusion, Flathub, and COPR repositories |
| `packages` | Install DNF packages from `packages/dnf-packages.txt` |
| `flatpaks` | Install Flatpak apps from `packages/flatpaks.txt` |
| `dotnet` | Install .NET SDK to `~/.dotnet` |
| `jetbrains` | Install JetBrains Toolbox App |
| `claude` | Install Claude Code CLI |
| `docker` | Install Docker Engine from official repository |
| `dotfiles` | Symlink dotfiles using GNU Stow |
| `kde` | Apply KDE Plasma settings |
| `services` | Enable/disable systemd services |

## Configuration

### DNF Packages

Edit `packages/dnf-packages.txt` - one package per line:

```bash
# Development tools
git
neovim
nodejs

# Package groups (prefix with @)
@development-tools

# Comments start with #
```

### Flatpak Apps

Edit `packages/flatpaks.txt` - one app ID per line:

```bash
com.spotify.Client
com.discordapp.Discord
com.visualstudio.code
```

Find app IDs at [Flathub](https://flathub.org).

### COPR Repositories

Edit `packages/copr-repos.txt`:

```bash
atim/lazygit
atim/starship
```

### Dotfiles (GNU Stow)

Each subdirectory in `dotfiles/` is a "stow package" that mirrors your home directory:

```
dotfiles/
├── bash/
│   └── .bashrc              → symlinks to ~/.bashrc
├── nvim/
│   └── .config/
│       └── nvim/
│           └── init.lua     → symlinks to ~/.config/nvim/init.lua
└── git/
    └── .gitconfig           → symlinks to ~/.gitconfig
```

**Adding your existing dotfiles:**

```bash
# Create a package for bash
mkdir -p dotfiles/bash
cp ~/.bashrc dotfiles/bash/

# Create a package for neovim
mkdir -p dotfiles/nvim/.config/nvim
cp -r ~/.config/nvim/* dotfiles/nvim/.config/nvim/

# Create a package for git
mkdir -p dotfiles/git
cp ~/.gitconfig dotfiles/git/
```

### Systemd Services

Edit `config/services.txt`:

```bash
# Enable and start services
sshd
docker
libvirtd

# Disable services (append :disable)
cups:disable

# Mask services (append :mask)
ModemManager:mask
```

### KDE Plasma Settings

Edit `config/kde-settings.sh` to customize your desktop. The script uses `kwriteconfig5`/`kwriteconfig6`:

```bash
# Set dark theme
run_kwrite --file kdeglobals --group General --key ColorScheme "BreezeDark"

# Set icon theme
run_kwrite --file kdeglobals --group Icons --key Theme "Papirus-Dark"

# Disable single-click to open
run_kwrite --file kdeglobals --group KDE --key SingleClick "false"
```

### DNF Optimization

The `config/dnf.conf` settings are automatically applied:

```ini
fastestmirror=True
max_parallel_downloads=10
defaultyes=True
keepcache=True
```

## What Gets Installed

By default, the script:

1. **Repositories** - Enables RPM Fusion (free + nonfree), Flathub, and your COPR repos
2. **System Update** - Runs `dnf update` after configuring repos
3. **DNF Packages** - Installs everything in `dnf-packages.txt`
4. **Flatpaks** - Installs everything in `flatpaks.txt`
5. **.NET SDK** - Installs to `~/.dotnet` using Microsoft's official installer
6. **JetBrains Toolbox** - Downloads and installs to `~/.local/share/JetBrains/Toolbox`
7. **Claude Code** - Installs the Claude Code CLI to `~/.local/bin`
8. **Docker** - Installs Docker Engine from official Docker repository, adds user to docker group
9. **Dotfiles** - Symlinks all stow packages to your home directory
10. **KDE Settings** - Applies your desktop customizations
11. **Services** - Enables/disables systemd services

## Version Control Tips

### Initial Setup

```bash
cd fedora-setup
git init
git add .
git commit -m "Initial setup configuration"
git remote add origin git@github.com:YOUR_USERNAME/fedora-setup.git
git push -u origin main
```

### .gitignore Recommendations

```gitignore
# Logs
*.log

# Sensitive files (if any)
dotfiles/**/credentials*
dotfiles/**/*.key

# OS files
.DS_Store
```

### Keeping Dotfiles in Sync

After making changes to your configs on your system:

```bash
# Your dotfiles are symlinks, so changes are already in the repo!
cd fedora-setup
git status
git add -A
git commit -m "Update configs"
git push
```

## Troubleshooting

### View Logs

```bash
cat setup.log
```

### Stow Conflicts

If Stow reports conflicts, it means files already exist. Use `--adopt` to pull them in:

```bash
cd fedora-setup
stow -v -d dotfiles -t ~ --adopt bash
```

### Re-run Specific Modules

```bash
sudo ./setup.sh --only packages
```

### Check What Would Happen

```bash
sudo ./setup.sh --dry-run
```

## Requirements

- Fedora (tested on Fedora 39+)
- KDE Plasma (for the kde module)
- Internet connection
- Root/sudo access

## License

MIT License - Feel free to fork and customize!
