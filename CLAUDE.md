# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Bash-based automation for fresh Fedora (KDE Plasma) installations. Modular scripts install packages, configure repositories, manage dotfiles via GNU Stow, and apply system settings.

## Commands

```bash
sudo ./setup.sh                      # Run full setup
sudo ./setup.sh --dry-run            # Preview changes without execution
sudo ./setup.sh --only repos,packages # Run specific modules only
sudo ./setup.sh --skip kde,services   # Skip specific modules
```

**Modules** (execution order): repos, packages, flatpaks, dotnet, jetbrains, claude, docker, fonts, dotfiles, kde, services

## Architecture

- `setup.sh` - Main orchestrator; exports shared functions (`log`, `warn`, `error`, `info`, `run_as_user`, `run_in_session`) and variables (`SCRIPT_DIR`, `LOG_FILE`, `DRY_RUN`, `ACTUAL_USER`, `ACTUAL_HOME`) to child scripts
- `scripts/*.sh` - Module scripts sourced by setup.sh; each handles one concern
- `packages/` - Plain text lists (one item per line, `#` for comments, inline comments supported): `dnf-packages.txt`, `flatpaks.txt`, `copr-repos.txt`
- `config/` - Configuration files: `dnf.conf`, `services.txt`, `kde-settings.sh`
- `dotfiles/` - GNU Stow packages; each subdirectory mirrors home directory structure

## Key Patterns

- Strict mode: `set -euo pipefail` in all scripts
- Dry-run: Check `$DRY_RUN` before destructive operations; use `[DRY RUN]` prefix in output
- Idempotent: Check if packages/repos already exist before installing
- Logging: Use `log()`, `warn()`, `error()`, `info()` functions; all output goes to `setup.log`
- Package groups: Prefix with `@` in dnf-packages.txt (e.g., `@development-tools`)
- Services format: `service_name` to enable, `service_name:disable` to disable, `service_name:mask` to mask

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
run_as_user fc-cache -fv "$ACTUAL_HOME/.local/share/fonts"
```

### `run_in_session` - Desktop Session Commands

For KDE tools, D-Bus commands, and anything requiring the user's active desktop session:

```bash
run_in_session kwriteconfig6 --file kdeglobals --group General --key fixed "Font,10"
run_in_session plasma-apply-lookandfeel -a org.kde.breezedark.desktop
run_in_session qdbus org.kde.KWin /KWin reconfigure
```

### When to Use Which

| Use `run_as_user` | Use `run_in_session` |
|-------------------|----------------------|
| File downloads | KDE settings (kwriteconfig) |
| Directory creation | Theme application |
| Font cache rebuild | D-Bus commands |
| Tool installations | Desktop notifications |
| Git operations | GUI app launches needing session |

### Available Variables

- `$ACTUAL_USER` - The real user (from `$SUDO_USER` or `$USER`)
- `$ACTUAL_HOME` - The real user's home directory

## User-Space Tool Installations

For tools installed to user home directories (e.g., ~/.dotnet, ~/.cargo, ~/.nvm):

1. **Run as actual user** - Use the `run_as_user` helper:
   ```bash
   run_as_user bash -c 'curl -sSL <url> | bash'
   ```

2. **Environment variables** - Add shell config to `dotfiles/bash/.bashrc.d/<toolname>`:
   ```bash
   export TOOL_ROOT="$HOME/.tool"
   export PATH="$PATH:$TOOL_ROOT/bin"
   ```
   Fedora's default .bashrc already sources all files in `~/.bashrc.d/`.

3. **Module ordering** - Place tool installation modules BEFORE `dotfiles` so the SDK is installed before shell config is deployed.
