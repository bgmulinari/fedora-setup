#!/bin/bash
#
# Flatpak Installation Module
# Installs Flatpak apps from packages/flatpaks.txt
#

log "Installing Flatpak applications..."

FLATPAKS_FILE="$SCRIPT_DIR/packages/flatpaks.txt"

install_flatpaks() {
    # Check if Flatpak is installed
    if ! command -v flatpak &> /dev/null; then
        dnf install -y flatpak
    fi

    # Check if Flathub is configured
    if ! flatpak remotes 2>/dev/null | grep -q "flathub"; then
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    fi

    if [[ ! -f "$FLATPAKS_FILE" ]]; then
        warn "Flatpak list not found: $FLATPAKS_FILE"
        info "Create this file with one app ID per line to install Flatpaks"
        return
    fi

    local apps=()

    # Read app IDs from file
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        # Trim whitespace
        line=$(echo "$line" | xargs)
        apps+=("$line")
    done < "$FLATPAKS_FILE"

    if [[ ${#apps[@]} -eq 0 ]]; then
        info "No Flatpak apps to install"
        return
    fi

    local app_total=${#apps[@]}
    log "Installing $app_total Flatpak apps..."

    local app_count=0
    for app in "${apps[@]}"; do
        ((app_count++))
        tui_set_substep "Installing Flatpak $app_count/$app_total: $app"
        # Check if already installed
        if flatpak list --app 2>/dev/null | grep -q "$app"; then
            info "Already installed: $app"
        else
            info "Installing: $app"
            flatpak install -y flathub "$app" >> "$LOG_FILE" 2>&1 || warn "Failed to install: $app"
        fi
    done
    tui_set_substep ""
}

# Execute
install_flatpaks

log "Flatpak installation complete!"
