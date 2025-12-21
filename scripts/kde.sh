#!/bin/bash
#
# KDE Plasma Configuration Module
# Applies KDE settings via kwriteconfig5/kwriteconfig6
#

log "Configuring KDE Plasma..."

ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(getent passwd "$ACTUAL_USER" | cut -d: -f6)

# Detect kwriteconfig version (KDE 5 vs 6)
if command -v kwriteconfig6 &> /dev/null; then
    KWRITE="kwriteconfig6"
elif command -v kwriteconfig5 &> /dev/null; then
    KWRITE="kwriteconfig5"
else
    warn "kwriteconfig not found. Is KDE Plasma installed?"
    exit 0
fi

# Run kwriteconfig as the actual user if running with sudo
run_kwrite() {
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would run: $KWRITE $*"
        return
    fi

    if [[ -n "$SUDO_USER" ]]; then
        sudo -u "$SUDO_USER" "$KWRITE" "$@"
    else
        "$KWRITE" "$@"
    fi
}

# Apply settings from config/kde-settings.sh if it exists
apply_custom_kde_settings() {
    local kde_script="$SCRIPT_DIR/config/kde-settings.sh"

    if [[ -f "$kde_script" ]]; then
        log "Applying custom KDE settings from $kde_script"
        if [[ "$DRY_RUN" == true ]]; then
            info "[DRY RUN] Would source: $kde_script"
        else
            # shellcheck source=/dev/null
            source "$kde_script"
        fi
    else
        info "No custom KDE settings file found at $kde_script"
        info "Creating example file..."
        create_example_kde_settings
    fi
}

# Create example KDE settings file
create_example_kde_settings() {
    local kde_script="$SCRIPT_DIR/config/kde-settings.sh"

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would create example KDE settings file"
        return
    fi

    cat > "$kde_script" << 'SETTINGS'
#!/bin/bash
#
# KDE Plasma Settings
# Customize these settings for your preferences
# Uses kwriteconfig5 or kwriteconfig6 (auto-detected)
#

# ═══════════════════════════════════════════════════════════════
# APPEARANCE
# ═══════════════════════════════════════════════════════════════

# Color scheme (e.g., "BreezeDark", "BreezeLight", "BreezeClassic")
# run_kwrite --file kdeglobals --group General --key ColorScheme "BreezeDark"

# Icon theme (e.g., "breeze-dark", "breeze", "Papirus-Dark")
# run_kwrite --file kdeglobals --group Icons --key Theme "breeze-dark"

# Cursor theme (e.g., "breeze_cursors", "Breeze_Snow")
# run_kwrite --file kcminputrc --group Mouse --key cursorTheme "breeze_cursors"

# ═══════════════════════════════════════════════════════════════
# DESKTOP BEHAVIOR
# ═══════════════════════════════════════════════════════════════

# Single-click to open files (false = double-click)
# run_kwrite --file kdeglobals --group KDE --key SingleClick "false"

# ═══════════════════════════════════════════════════════════════
# FONTS
# ═══════════════════════════════════════════════════════════════

# General font
# run_kwrite --file kdeglobals --group General --key font "Noto Sans,10,-1,5,50,0,0,0,0,0"

# Fixed-width font
# run_kwrite --file kdeglobals --group General --key fixed "JetBrains Mono,10,-1,5,50,0,0,0,0,0"

# ═══════════════════════════════════════════════════════════════
# KONSOLE
# ═══════════════════════════════════════════════════════════════

# Default Konsole profile is set via ~/.local/share/konsole/ profiles

# ═══════════════════════════════════════════════════════════════
# SHORTCUTS
# ═══════════════════════════════════════════════════════════════

# Example: Set Meta+E to open Dolphin
# run_kwrite --file kglobalshortcutsrc --group org.kde.dolphin.desktop --key _launch "Meta+E,Meta+E,Dolphin"

SETTINGS

    chmod +x "$kde_script"
    info "Created example KDE settings file: $kde_script"
    info "Edit this file to customize your KDE settings"
}

# Refresh KDE to apply changes
refresh_kde() {
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would refresh KDE configuration"
        return
    fi

    # Refresh KDE config
    if command -v qdbus &> /dev/null; then
        if [[ -n "$SUDO_USER" ]]; then
            sudo -u "$SUDO_USER" qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
        else
            qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
        fi
    fi

    info "KDE settings refreshed (some changes may require logout)"
}

# Execute
apply_custom_kde_settings
refresh_kde

log "KDE Plasma configuration complete!"
