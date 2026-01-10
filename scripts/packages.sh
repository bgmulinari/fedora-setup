#!/bin/bash
#
# DNF Package Installation Module
# Installs packages from packages/dnf-packages.txt
#

log "Installing DNF packages..."

PACKAGES_FILE="$SCRIPT_DIR/packages/dnf-packages.txt"

install_packages() {
    if [[ ! -f "$PACKAGES_FILE" ]]; then
        warn "Package list not found: $PACKAGES_FILE"
        info "Create this file with one package per line to install packages"
        return
    fi

    local packages=()
    local groups=()

    # Read packages from file
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        # Strip inline comments and trim whitespace
        line="${line%%#*}"
        line=$(echo "$line" | xargs)

        # Skip if empty after stripping comment
        [[ -z "$line" ]] && continue

        # Check if it's a group (starts with @)
        if [[ "$line" == @* ]]; then
            groups+=("$line")
        else
            packages+=("$line")
        fi
    done < "$PACKAGES_FILE"

    # Install groups
    if [[ ${#groups[@]} -gt 0 ]]; then
        log "Installing package groups..."
        for group in "${groups[@]}"; do
            info "Installing group: $group"
            dnf group install -y "$group" || warn "Failed to install group: $group"
        done
    fi

    # Install packages
    if [[ ${#packages[@]} -gt 0 ]]; then
        log "Installing ${#packages[@]} packages..."

        # Install all packages in one command for efficiency
        dnf install -y "${packages[@]}" || {
            warn "Some packages failed to install, trying one by one..."
            for pkg in "${packages[@]}"; do
                dnf install -y "$pkg" || warn "Failed to install: $pkg"
            done
        }
    else
        info "No packages to install"
    fi
}

# Execute
install_packages

log "DNF package installation complete!"
