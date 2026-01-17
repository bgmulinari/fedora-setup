# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Bash-based automation for fresh Fedora (KDE Plasma) installations. Modular scripts install packages, configure repositories, manage dotfiles via GNU Stow, and apply system settings.

## Commands

```bash
# Remote install (no local clone needed)
sh <(curl -L https://raw.githubusercontent.com/bgmulinari/fedora-setup/master/auto-install.sh)

# Local install
sudo ./setup.sh                       # Run full setup (with TUI)
sudo ./setup.sh --yes                 # Skip confirmation prompt
sudo ./setup.sh --no-tui              # Run with plain text output
sudo ./setup.sh --only repos,packages # Run specific modules only
sudo ./setup.sh --skip kde            # Skip specific modules
```

**Modules** (execution order): repos, multimedia, packages, flatpaks, dotnet, jetbrains, claude, docker, fonts, catppuccin, icons, dotfiles, zsh, kde

## Architecture

- `auto-install.sh` - Bootstrap script for remote execution; clones repo and runs setup.sh
- `setup.sh` - Main orchestrator; exports shared functions (`log`, `warn`, `error`, `info`, `run_as_user`, `run_in_session`) and variables (`SCRIPT_DIR`, `LOG_FILE`, `ACTUAL_USER`, `ACTUAL_HOME`) to child scripts
- `lib/tui.sh` - TUI library providing split-view terminal interface with progress tracking
- `lib/kde.sh` - KDE helper library with kwriteconfig detection and wrapper functions (`kde_write`, `kde_apply_theme`, `kde_available`)
- `scripts/*.sh` - Module scripts sourced by setup.sh; each handles one concern
- `packages/` - Plain text lists (one item per line, `#` for comments): `dnf-packages.txt`, `flatpaks.txt`, `copr-repos.txt`
- `config/` - Configuration files: `dnf.conf`
- `dotfiles/` - GNU Stow packages; each subdirectory mirrors home directory structure

## Key Patterns

- Strict mode: `set -euo pipefail` in all scripts
- Idempotent: Check if packages/repos already exist before installing
- Logging: Use `log()`, `warn()`, `error()`, `info()` functions; all output goes to `setup.log`
- Package groups: Prefix with `@` in dnf-packages.txt (e.g., `@development-tools`)
- Package removal: Prefix with `-` in dnf-packages.txt (e.g., `-libreoffice*`)

## Adding New Modules

1. Create `scripts/newmodule.sh`
2. Add module name to `ALL_MODULES` in setup.sh
3. Add `run_module "newmodule"` call in main()

## Running Commands as User (Not Root)

When running under `sudo`, commands run as root by default. Use these exported helpers:

### `run_as_user` - File Operations

For downloads, file creation, and commands that write to user's home directory:

```bash
run_as_user mkdir -p "$ACTUAL_HOME/.local/bin"
run_as_user curl -fsSL "$URL" -o "$ACTUAL_HOME/file"
run_as_user bash -c 'curl -sSL <url> | bash'  # For piped commands
```

### `run_in_session` - Desktop Session Commands

For KDE tools, D-Bus commands, and anything requiring the user's active desktop session:

```bash
run_in_session kwriteconfig6 --file kdeglobals --group General --key fixed "Font,10"
run_in_session plasma-apply-lookandfeel -a org.kde.breezedark.desktop
```

### When to Use Which

| Use `run_as_user` | Use `run_in_session` |
|-------------------|----------------------|
| File downloads | KDE settings (kwriteconfig) |
| Directory creation | Theme application |
| Font cache rebuild | D-Bus commands |
| Tool installations | GUI app launches needing session |

### Available Variables

- `$ACTUAL_USER` - The real user (from `$SUDO_USER` or `$USER`)
- `$ACTUAL_HOME` - The real user's home directory
