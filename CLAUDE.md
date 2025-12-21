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

**Modules** (execution order): repos, packages, flatpaks, dotnet, jetbrains, claude, docker, dotfiles, kde, services

## Architecture

- `setup.sh` - Main orchestrator; exports shared functions (`log`, `warn`, `error`, `info`) and variables (`SCRIPT_DIR`, `LOG_FILE`, `DRY_RUN`) to child scripts
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

## User-Space Tool Installations

For tools installed to user home directories (e.g., ~/.dotnet, ~/.cargo, ~/.nvm):

1. **Run as actual user** - Use `SUDO_USER` to get the real user when running under sudo:
   ```bash
   ACTUAL_USER="${SUDO_USER:-$USER}"
   ACTUAL_HOME=$(getent passwd "$ACTUAL_USER" | cut -d: -f6)
   sudo -u "$ACTUAL_USER" bash -c 'curl -sSL <url> | bash'
   ```

2. **Environment variables** - Add shell config to `dotfiles/bash/.bashrc.d/<toolname>`:
   ```bash
   export TOOL_ROOT="$HOME/.tool"
   export PATH="$PATH:$TOOL_ROOT/bin"
   ```
   Fedora's default .bashrc already sources all files in `~/.bashrc.d/`.

3. **Module ordering** - Place tool installation modules BEFORE `dotfiles` so the SDK is installed before shell config is deployed.
