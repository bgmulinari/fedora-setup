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
        local group_count=0
        local group_total=${#groups[@]}
        for group in "${groups[@]}"; do
            ((group_count++))
            tui_set_substep "Installing group $group_count/$group_total: $group"
            info "Installing group: $group"
            dnf group install -y "$group" >> "$LOG_FILE" 2>&1 || warn "Failed to install group: $group"
        done
    fi

    # Install packages
    if [[ ${#packages[@]} -gt 0 ]]; then
        local pkg_total=${#packages[@]}
        log "Installing $pkg_total packages..."
        tui_set_substep "Installing $pkg_total packages (batch mode)..."

        # Install all packages in one command for efficiency
        if dnf install -y "${packages[@]}" >> "$LOG_FILE" 2>&1; then
            tui_set_substep "All packages installed successfully"
        else
            warn "Some packages failed to install, trying one by one..."
            local pkg_count=0
            for pkg in "${packages[@]}"; do
                ((pkg_count++))
                tui_set_substep "Installing package $pkg_count/$pkg_total: $pkg"
                dnf install -y "$pkg" >> "$LOG_FILE" 2>&1 || warn "Failed to install: $pkg"
            done
        fi
    else
        info "No packages to install"
    fi
    tui_set_substep ""
}

# Execute
install_packages

log "DNF package installation complete!"
