#!/bin/bash
#
# KDE Plasma Configuration Module
# Applies KDE settings via plasma-apply-* and kwriteconfig tools

set -euo pipefail

# Logging functions (standalone since this runs as subprocess)
# Log file may not be writable (owned by root), so we check first
_log_to_file() {
    [[ -w "$LOG_FILE" ]] && echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log() {
    echo -e "\033[0;32m==>\033[0m $1"
    _log_to_file "$1"
}

warn() {
    echo -e "\033[1;33m==> WARNING:\033[0m $1"
    _log_to_file "WARNING: $1"
}

info() {
    echo -e "\033[0;34m    $1\033[0m"
}

log "Configuring KDE Plasma..."

# Detect kwriteconfig version (KDE 5 vs 6)
if command -v kwriteconfig6 &> /dev/null; then
    KWRITE="kwriteconfig6"
elif command -v kwriteconfig5 &> /dev/null; then
    KWRITE="kwriteconfig5"
else
    warn "kwriteconfig not found. Is KDE Plasma installed?"
    exit 0
fi

# Run kwriteconfig in user's session context
run_kwrite() {
    info "Applying settings via user session..."
    run_in_session "$KWRITE" "$@"
}

# Detect look-and-feel tool (KDE 6 vs 5)
if command -v plasma-apply-lookandfeel &> /dev/null; then
    LOOKANDFEEL="plasma-apply-lookandfeel"
elif command -v lookandfeeltool &> /dev/null; then
    LOOKANDFEEL="lookandfeeltool"
else
    LOOKANDFEEL=""
fi

# Apply look-and-feel theme
run_lookandfeel() {
    local theme="$1"

    if [[ -z "$LOOKANDFEEL" ]]; then
        warn "No look-and-feel tool found. Cannot set global theme."
        return 1
    fi

    info "Applying theme via user session..."
    run_in_session "$LOOKANDFEEL" -a "$theme"
}

# Apply settings from config/kde-settings.sh if it exists
apply_custom_kde_settings() {
    local kde_script="$SCRIPT_DIR/config/kde-settings.sh"

    if [[ -f "$kde_script" ]]; then
        log "Applying custom KDE settings from $kde_script"
        # shellcheck source=/dev/null
        source "$kde_script"
    else
        info "No custom KDE settings file found at $kde_script"
    fi
}

# Execute
apply_custom_kde_settings

log "KDE Plasma configuration complete!"
