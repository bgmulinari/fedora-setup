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
│   ├── tui.sh               # TUI library (progress display)
│   └── kde.sh               # KDE helper library (kwriteconfig wrappers)
├── packages/
│   ├── dnf-packages.txt     # DNF packages to install
│   ├── flatpaks.txt         # Flatpak apps to install
│   ├── copr-repos.txt       # COPR repositories to enable
│   └── brew-packages.txt    # Homebrew packages to install
├── dotfiles/                # Stow-managed dotfiles
│   ├── bash/                # Bash configs (.bashrc.d/)
│   ├── btop/                # btop system monitor config
│   ├── claude/              # Claude Code settings
│   ├── ghostty/             # Ghostty terminal config
│   ├── nvim/                # Neovim config (LazyVim)
│   ├── shell/               # Shared shell configs (.shellrc.d/)
│   ├── starship/            # Starship prompt config
│   ├── vscode/              # VS Code settings
│   └── zsh/                 # Zsh configs (.zshrc, .zshrc.d/)
├── config/
│   └── dnf.conf             # DNF performance settings
└── scripts/                 # Module scripts
    ├── repos.sh             # Repository setup (RPM Fusion, Flathub, COPR)
    ├── multimedia.sh        # Video codecs and hardware acceleration
    ├── packages.sh          # DNF package installation
    ├── flatpaks.sh          # Flatpak installation
    ├── homebrew.sh          # Homebrew and brew packages
    ├── dotnet.sh            # .NET SDK installation
    ├── jetbrains.sh         # JetBrains Toolbox installation
    ├── claude.sh            # Claude Code CLI installation
    ├── devtunnel.sh         # Microsoft Dev Tunnel CLI installation
    ├── docker.sh            # Docker Engine installation
    ├── fonts.sh             # JetBrainsMono Nerd Font and Microsoft fonts
    ├── catppuccin.sh        # Catppuccin theme installation
    ├── icons.sh             # Icon theme installation (Papirus)
    ├── dotfiles.sh          # GNU Stow dotfiles
    ├── zsh.sh               # Zsh with Oh My Zsh and plugins
    └── kde.sh               # KDE configuration
```

## Usage

```bash
sudo ./setup.sh                       # Run full setup (with TUI)
sudo ./setup.sh -y                    # Skip confirmation prompt
sudo ./setup.sh --no-tui              # Run with plain text output
sudo ./setup.sh --only repos,packages # Run specific modules
sudo ./setup.sh --skip kde            # Skip specific modules
```

### Available Modules

| Module | Description |
|--------|-------------|
| `repos` | Enable RPM Fusion, Flathub, COPR repos, VS Code repo |
| `multimedia` | Install video codecs (ffmpeg, GStreamer) and hardware acceleration |
| `packages` | Install DNF packages from `packages/dnf-packages.txt` |
| `flatpaks` | Install Flatpak apps from `packages/flatpaks.txt` |
| `homebrew` | Install Homebrew and packages from `packages/brew-packages.txt` |
| `dotnet` | Install .NET SDK to `~/.dotnet` |
| `jetbrains` | Install JetBrains Toolbox App |
| `claude` | Install Claude Code CLI |
| `devtunnel` | Install Microsoft Dev Tunnel CLI |
| `docker` | Install Docker Engine, add user to docker group |
| `fonts` | Install JetBrainsMono Nerd Font and Microsoft core fonts |
| `catppuccin` | Install and apply Catppuccin Mocha theme (KDE, GTK, VS Code, btop) |
| `icons` | Install and apply Papirus icon theme with breeze folders |
| `dotfiles` | Symlink dotfiles using GNU Stow |
| `zsh` | Install Oh My Zsh with plugins (autosuggestions, syntax-highlighting) and Catppuccin theme |
| `kde` | Apply KDE keybindings and terminal settings |

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

# Remove packages with - prefix
-libreoffice*
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

### Homebrew Packages

Edit `packages/brew-packages.txt`:

```bash
lazydocker
```

Find packages at [Homebrew Formulae](https://formulae.brew.sh).

### Dotfiles (GNU Stow)

Each subdirectory in `dotfiles/` mirrors your home directory:

```
dotfiles/shell/.shellrc.d/dotnet         →  ~/.shellrc.d/dotnet    (shared by bash/zsh)
dotfiles/zsh/.zshrc                      →  ~/.zshrc
dotfiles/starship/.config/starship.toml  →  ~/.config/starship.toml
dotfiles/ghostty/.config/ghostty/config  →  ~/.config/ghostty/config
dotfiles/nvim/.config/nvim/init.lua      →  ~/.config/nvim/init.lua
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
