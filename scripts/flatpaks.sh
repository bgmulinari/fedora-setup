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
        if [[ "$DRY_RUN" == true ]]; then
            info "[DRY RUN] Would install flatpak"
        else
            dnf install -y flatpak
        fi
    fi

    # Check if Flathub is configured
    if ! flatpak remotes 2>/dev/null | grep -q "flathub"; then
        if [[ "$DRY_RUN" == true ]]; then
            info "[DRY RUN] Would add Flathub remote"
        else
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        fi
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

    log "Installing ${#apps[@]} Flatpak apps..."

    for app in "${apps[@]}"; do
        if [[ "$DRY_RUN" == true ]]; then
            info "[DRY RUN] Would install: $app"
        else
            # Check if already installed
            if flatpak list --app 2>/dev/null | grep -q "$app"; then
                info "Already installed: $app"
            else
                info "Installing: $app"
                flatpak install -y flathub "$app" || warn "Failed to install: $app"
            fi
        fi
    done
}

# Execute
install_flatpaks

log "Flatpak installation complete!"
