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
        systemd-run --uid="$(id -u "$SUDO_USER")" --machine="$SUDO_USER@" --user "$@"
    else
        "$@"
    fi
}

# Available modules
ALL_MODULES="repos packages flatpaks dotnet jetbrains claude docker fonts dotfiles kde services"

# Source TUI library (after ALL_MODULES is defined)
source "$SCRIPT_DIR/lib/tui.sh"

# Default settings
SKIP_MODULES=""
ONLY_MODULES=""
TUI_DISABLED=0

# Parse command line arguments
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Fedora Auto-Setup Script

OPTIONS:
    -h, --help          Show this help message
    --skip MODULES      Skip specified modules (comma-separated)
    --only MODULES      Run only specified modules (comma-separated)
    --no-tui            Disable TUI mode (use plain output)

MODULES:
    repos       Enable RPM Fusion, Flathub, COPR repositories
    packages    Install DNF packages from packages/dnf-packages.txt
    flatpaks    Install Flatpak apps from packages/flatpaks.txt
    jetbrains   Install JetBrains Toolbox App
    claude      Install Claude Code CLI
    docker      Install Docker Engine from official repository
    fonts       Install JetBrainsMono Nerd Font
    dotfiles    Symlink dotfiles from dotfiles/ to home directory
    kde         Apply KDE Plasma settings
    services    Enable/start systemd services

EXAMPLES:
    $(basename "$0")                      # Run full setup
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
            --no-tui)
                TUI_DISABLED=1
                shift
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
        info "Skipping $module (excluded by options)"
        return 0
    fi

    if [[ ! -f "$script" ]]; then
        tui_skip_module "$module"
        warn "Module script not found: $script"
        return 0
    fi

    tui_start_module "$module"
    log "Running module: $module"

    # shellcheck source=/dev/null
    if source "$script"; then
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

    # Initialize TUI (unless disabled)
    if [[ $TUI_DISABLED -eq 0 ]]; then
        tui_init
        trap 'tui_cleanup' EXIT
    fi

    # Show banner in non-TUI mode
    if [[ $TUI_ENABLED -eq 0 ]]; then
        echo ""
        echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║     Fedora Auto-Setup Script             ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
        echo ""
    fi

    # Check privileges (skip for dotfiles-only runs as regular user)
    if should_run_module "repos" || should_run_module "packages" || should_run_module "services"; then
        check_privileges
    fi

    # Run modules in order
    run_module "repos"
    run_module "packages"
    run_module "flatpaks"
    run_module "dotnet"
    run_module "jetbrains"
    run_module "claude"
    run_module "docker"
    run_module "fonts"
    run_module "dotfiles"
    run_module "kde"
    run_module "services"

    echo ""
    log "Setup complete!"
    echo ""
    info "Log file: $LOG_FILE"

    # Prompt for reboot if system packages were installed
    if should_run_module "packages"; then
        echo ""
        read -rp "Reboot now? [y/N] " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            reboot
        fi
    fi
}

main "$@"
