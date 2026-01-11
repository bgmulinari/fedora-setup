#!/bin/bash
#
# Icon Theme Module
# Installs Papirus icon theme with breeze-colored folders from KDE Store
#

set -euo pipefail

log "Installing icon themes..."

ICONS_DIR="$ACTUAL_HOME/.local/share/icons"

# Install Papirus icons with breeze-colored folders from KDE Store
install_papirus_icons() {
    if [[ -d "$ICONS_DIR/Papirus-Dark" ]]; then
        info "Papirus icons already installed"
        return 0
    fi

    log "Installing Papirus icons..."
    run_as_user mkdir -p "$ICONS_DIR"

    # Get download URL from KDE Store OCS API (content ID 1166289, file 5 = breeze-folders)
    local api_url="https://api.kde-look.org/ocs/v1/content/download/1166289/5"
    local download_url
    download_url=$(curl -sL "$api_url" | grep -oP 'downloadlink>[^<]+' | cut -d'>' -f2)

    if [[ -z "$download_url" ]]; then
        warn "Failed to get Papirus download URL from KDE Store"
        return 1
    fi

    local tmp_file="/tmp/papirus-icons-$$.tar.xz"
    run_as_user curl -fsSL -o "$tmp_file" "$download_url"
    run_as_user tar -xf "$tmp_file" -C "$ICONS_DIR"
    rm -f "$tmp_file"

    info "Papirus icons installed"
}

install_papirus_icons

# Apply icon theme in KDE if available
apply_icon_theme() {
    kde_available || return 0
    [[ -d "$ICONS_DIR/Papirus-Dark" ]] || return 0

    log "Applying Papirus-Dark icon theme..."
    kde_write --file kdeglobals --group Icons --key Theme "Papirus-Dark"
}

apply_icon_theme

log "Icon themes installed!"
