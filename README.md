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

## What Gets Installed

- **Repositories** — RPM Fusion (free + nonfree), Flathub, Cisco OpenH264, VS Code repo, Claude Desktop repo, COPR repos (ghostty, gowall, starship, lazygit, helium)
- **DNF Packages** — zsh, code, claude-desktop, gh, fastfetch, ghostty, btop, neovim, gowall, fd-find, fzf, starship, zoxide, bat, helium-bin, lazygit (removes libreoffice\*)
- **Flatpak Apps** — OnlyOffice, Spotify, Discord, Teams for Linux, Zoom
- **GitHub RPMs** — Bruno (API client)
- **Homebrew Packages** — lazydocker, codex
- **Multimedia Codecs** — ffmpeg (full), GStreamer plugins, OpenH264, LAME, VA-API
- **Docker** — docker-ce, docker-ce-cli, containerd.io, buildx plugin, compose plugin
- **.NET SDK** — all active non-EOL channels + global tools: csharp-ls, dotnet-ef, dotnet-repl, ilspycmd, linux-dev-certs, powershell, volo.abp.studio.cli
- **Other Tools** — JetBrains Toolbox, Claude Code CLI, Claude Desktop, Microsoft Dev Tunnel CLI
- **Fonts** — JetBrainsMono Nerd Font, Inter, Microsoft Core Fonts
- **Themes & Icons** — Catppuccin Mocha Blue (KDE, GTK, VS Code, btop, zsh-syntax-highlighting), Papirus-Dark icons
- **Shell** — Oh My Zsh + plugins (zsh-autosuggestions, zsh-syntax-highlighting), Starship prompt
- **Dotfiles** — symlinked via GNU Stow (bash, zsh, starship, ghostty, nvim, btop, claude, vscode)
- **KDE** — keybindings and terminal settings

## Usage

```bash
sudo ./setup.sh                       # Run full setup (with TUI)
sudo ./setup.sh --only repos,packages # Run specific modules
sudo ./setup.sh --skip kde            # Skip specific modules
```

## Configuration

Package lists live in `packages/` — one item per line, `#` for comments. Special prefixes: `@` for DNF groups (e.g., `@development-tools`), `-` for removal (e.g., `-libreoffice*`).

Dotfiles are managed with GNU Stow. Each subdirectory in `dotfiles/` mirrors the home directory structure and gets symlinked during setup.

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
