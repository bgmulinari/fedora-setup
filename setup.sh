#!/bin/bash
#
# Fedora Auto-Setup Script
# Automates fresh Fedora (KDE Plasma) installation
#

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/setup.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Export colors for TUI library
export RED GREEN YELLOW BLUE NC

# Script title
SCRIPT_TITLE="Fedora KDE Plasma Desktop Setup"
export SCRIPT_TITLE

# Logging functions
log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo -e "${GREEN}==>${NC} $1"
    echo "$msg" >> "$LOG_FILE"
}

warn() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $1"
    echo -e "${YELLOW}==> WARNING:${NC} $1"
    echo "$msg" >> "$LOG_FILE"
}

error() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1"
    echo -e "${RED}==> ERROR:${NC} $1" >&2
    echo "$msg" >> "$LOG_FILE"
}

info() {
    echo -e "${BLUE}    $1${NC}"
}

# User context for running commands as actual user (not root) under sudo
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(getent passwd "$ACTUAL_USER" | cut -d: -f6)

# Run command as actual user (for file operations, downloads, etc.)
run_as_user() {
    if [[ -n "${SUDO_USER:-}" ]]; then
        sudo -u "$SUDO_USER" "$@"
    else
        "$@"
    fi
}

# Run command in user's desktop session (for KDE, D-Bus, GUI apps)
run_in_session() {
    if [[ -n "${SUDO_USER:-}" ]]; then
        local uid
        uid=$(id -u "$SUDO_USER")
        sudo -u "$SUDO_USER" \
            XDG_RUNTIME_DIR="/run/user/$uid" \
            DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
            "$@"
    else
        "$@"
    fi
}

# Available modules (order matters!)
# dotfiles must run AFTER modules that create default configs (e.g., zsh installs Oh My Zsh
# which creates ~/.zshrc). Running dotfiles last ensures our custom configs overwrite defaults.
ALL_MODULES="repos multimedia packages flatpaks homebrew dotnet jetbrains claude devtunnel docker fonts catppuccin icons zsh dotfiles kde"

# Module descriptions (single source of truth for usage, TUI, etc.)
declare -A MODULE_DESC=(
    [repos]="RPM Fusion · Flathub · COPR repositories"
    [multimedia]="Video codecs and hardware acceleration"
    [packages]="DNF packages from dnf-packages.txt"
    [flatpaks]="Flatpak apps from flatpaks.txt"
    [homebrew]="Homebrew and packages from brew-packages.txt"
    [dotnet]=".NET SDK and global tools"
    [jetbrains]="JetBrains Toolbox App"
    [claude]="Claude Code CLI"
    [devtunnel]="Microsoft Dev Tunnel CLI"
    [docker]="Docker Engine"
    [fonts]="JetBrainsMono Nerd Font · Inter · Microsoft fonts"
    [catppuccin]="Catppuccin Mocha theme for KDE · GTK · VS Code · btop"
    [icons]="Papirus icon theme"
    [zsh]="Oh My Zsh with plugins"
    [dotfiles]="Symlink dotfiles via GNU Stow"
    [kde]="KDE Plasma settings and keybindings"
)

# Source TUI library (after ALL_MODULES is defined)
source "$SCRIPT_DIR/lib/tui.sh"

# Source KDE helper library
source "$SCRIPT_DIR/lib/kde.sh"

# Default settings
SKIP_MODULES=""
ONLY_MODULES=""

# Parse command line arguments
usage() {
    cat << EOF
$SCRIPT_TITLE

Usage: $(basename "$0") [OPTIONS]

OPTIONS:
    -h, --help          Show this help message
    --skip MODULES      Skip specified modules (comma-separated)
    --only MODULES      Run only specified modules (comma-separated)

MODULES:
$(for mod in $ALL_MODULES; do printf "    %-12s %s\n" "$mod" "${MODULE_DESC[$mod]}"; done)

EXAMPLES:
    $(basename "$0")    # Run full setup
    $(basename "$0") --only repos,packages
    $(basename "$0") --skip flatpaks,kde

EOF
    exit 0
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                ;;
            --skip)
                SKIP_MODULES="$2"
                shift 2
                ;;
            --only)
                ONLY_MODULES="$2"
                shift 2
                ;;
            *)
                error "Unknown option: $1"
                usage
                ;;
        esac
    done
}

# Check if a module should run
should_run_module() {
    local module="$1"

    # If --only is specified, only run those modules
    if [[ -n "$ONLY_MODULES" ]]; then
        if [[ ",$ONLY_MODULES," == *",$module,"* ]]; then
            return 0
        else
            return 1
        fi
    fi

    # If --skip is specified, skip those modules
    if [[ -n "$SKIP_MODULES" ]]; then
        if [[ ",$SKIP_MODULES," == *",$module,"* ]]; then
            return 1
        fi
    fi

    return 0
}

# Run a module script
run_module() {
    local module="$1"
    local script="$SCRIPT_DIR/scripts/${module}.sh"

    if ! should_run_module "$module"; then
        tui_skip_module "$module"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Skipped module: $module" >> "$LOG_FILE"
        return 0
    fi

    if [[ ! -f "$script" ]]; then
        tui_skip_module "$module"
        warn "Module script not found: $script"
        return 0
    fi

    tui_start_module "$module"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running module: $module" >> "$LOG_FILE"

    if tui_run_module "$module" "$script"; then
        tui_end_module "$module" "done"
    else
        tui_end_module "$module" "error"
    fi
}

# Check for root/sudo
check_privileges() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root or with sudo"
        exit 1
    fi
}

# Export variables and functions for child scripts
export SCRIPT_DIR LOG_FILE ACTUAL_USER ACTUAL_HOME ALL_MODULES
export -f log warn error info run_as_user run_in_session

# Main execution
main() {
    parse_args "$@"

    # Log start
    echo "=== Setup started at $(date) ===" >> "$LOG_FILE"

    # Initialize TUI
    tui_init
    trap 'tui_cleanup' EXIT

    # Show banner
    tui_banner

    # Interactive module selection
    if ! tui_select_modules; then
        echo ""
        echo "No modules selected to run. Setup cancelled."
        exit 0
    fi

    # Build run/skip lists from selection and show plan
    local modules_to_run="" modules_to_skip=""
    local module
    for module in $ALL_MODULES; do
        if should_run_module "$module"; then
            modules_to_run+=" $module"
        else
            modules_to_skip+=" $module"
        fi
    done
    tui_show_plan "$modules_to_run" "$modules_to_skip"

    # Confirm before running
    if ! tui_confirm "Proceed with setup?"; then
        echo "Setup cancelled."
        exit 0
    fi

    # Clear selection/plan screen and redraw banner for progress view
    tui_banner

    echo ""
    gum style --bold "Installing selected modules... this may take some time. Please wait!"

    # Check privileges (skip for dotfiles-only runs as regular user)
    if should_run_module "repos" || should_run_module "multimedia" || should_run_module "packages" || should_run_module "fonts"; then
        check_privileges
    fi

    # Run modules in order
    run_module "repos"
    run_module "multimedia"
    run_module "packages"
    run_module "flatpaks"
    run_module "homebrew"
    run_module "dotnet"
    run_module "jetbrains"
    run_module "claude"
    run_module "devtunnel"
    run_module "docker"
    run_module "fonts"
    run_module "catppuccin"
    run_module "icons"
    run_module "zsh"
    run_module "dotfiles"
    run_module "kde"

    # Show summary
    tui_summary

    # Prompt for reboot if system packages were installed
    if should_run_module "packages"; then
        echo ""
        if tui_confirm "Reboot now?"; then
            reboot
        fi
    fi
}

main "$@"
