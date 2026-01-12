#!/bin/bash
#
# KDE Plasma Configuration Module
# Applies keybindings and general settings
# Resource-specific settings (icons, themes, fonts) are applied by their modules
#

set -euo pipefail

log "Configuring KDE Plasma..."

if ! kde_available; then
    warn "KDE tools not found. Is KDE Plasma installed?"
    exit 0
fi

# Apply resource-specific settings ONLY if resource exists
# This handles the case where kde runs but catppuccin/icons/fonts modules didn't
apply_conditional_resource_settings() {
    # Catppuccin look-and-feel
    local catppuccin_dir="$ACTUAL_HOME/.local/share/plasma/look-and-feel/Catppuccin-Mocha-Blue"
    if [[ -d "$catppuccin_dir" ]]; then
        log "Applying Catppuccin Mocha Blue look-and-feel..."
        kde_apply_theme "Catppuccin-Mocha-Blue"

        # GTK theme
        local gtk_theme_dir="$ACTUAL_HOME/.local/share/themes/catppuccin-mocha-blue-standard+default"
        if [[ -d "$gtk_theme_dir" ]]; then
            log "Setting GTK theme..."
            kde_write --file gtk-3.0/settings.ini --group Settings --key gtk-theme-name "catppuccin-mocha-blue-standard+default"
            kde_write --file gtk-4.0/settings.ini --group Settings --key gtk-theme-name "catppuccin-mocha-blue-standard+default"
        fi
    else
        info "Catppuccin theme not installed, skipping theme application"
    fi

    # Papirus icons
    if [[ -d "$ACTUAL_HOME/.local/share/icons/Papirus-Dark" ]]; then
        log "Applying Papirus-Dark icon theme..."
        kde_write --file kdeglobals --group Icons --key Theme "Papirus-Dark"
    else
        info "Papirus icons not installed, skipping icon theme"
    fi

    # JetBrainsMono fixed font
    local font_dir="$ACTUAL_HOME/.local/share/fonts/JetBrainsMonoNerdFont"
    if [[ -d "$font_dir" ]]; then
        log "Setting JetBrainsMono as fixed-width font..."
        kde_write --file kdeglobals --group General --key fixed "JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"
    else
        info "JetBrainsMono font not installed, skipping font setting"
    fi
}

# Apply terminal settings (only if Ghostty is installed)
apply_terminal_settings() {
    if ! command -v ghostty &>/dev/null; then
        info "Ghostty not installed, skipping terminal settings"
        return 0
    fi

    log "Applying terminal settings..."
    kde_write --file kdeglobals --group General --key TerminalApplication "ghostty"
    kde_write --file kdeglobals --group General --key TerminalService "com.mitchellh.ghostty.desktop"

    # Terminal shortcut: Meta+Return
    kde_write --file kglobalshortcutsrc --group services \
        --group com.mitchellh.ghostty.desktop --key "_launch" "Meta+Return"
}

# Apply virtual desktop keybindings
apply_keybind_settings() {
    log "Applying keybind settings..."

    # Unbind Meta+[1-9] from task manager
    local i
    for i in {1..9}; do
        kde_write --file kglobalshortcutsrc --group plasmashell \
            --key "activate task manager entry $i" "none,Meta+$i,Activate Task Manager Entry $i"
    done

    # Bind Meta+[1-5] to virtual desktops
    for i in {1..5}; do
        kde_write --file kglobalshortcutsrc --group kwin \
            --key "Switch to Desktop $i" "Meta+$i,Ctrl+F$i,Switch to Desktop $i"
    done
}

# Apply desktop settings
apply_desktop_settings() {
    log "Enabling desktop settings..."
    kde_write --file kwinrc --group Plugins --key blurEnabled true
    kde_write --file kdeglobals --group KDE --key AnimationDurationFactor 0.25
}

# Execute
apply_conditional_resource_settings
apply_terminal_settings
apply_keybind_settings
apply_desktop_settings

log "KDE Plasma configuration complete!"
