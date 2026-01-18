#!/bin/bash
#
# Homebrew Installation Module
# Installs Homebrew and packages from brew-packages.txt
#

log "Setting up Homebrew..."

BREW_PREFIX="/home/linuxbrew/.linuxbrew"
PACKAGES_FILE="$SCRIPT_DIR/packages/brew-packages.txt"

install_homebrew() {
    if [[ -x "$BREW_PREFIX/bin/brew" ]]; then
        info "Homebrew already installed"
        return
    fi

    log "Installing Homebrew..."

    # Download and run installer as user (non-interactive)
    run_as_user bash -c 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' >> "$LOG_FILE" 2>&1

    log "Homebrew installed successfully"
}

install_packages() {
    if [[ ! -f "$PACKAGES_FILE" ]]; then
        info "No brew packages file found, skipping"
        return
    fi

    local packages=()
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        line=$(echo "$line" | xargs)
        packages+=("$line")
    done < "$PACKAGES_FILE"

    if [[ ${#packages[@]} -eq 0 ]]; then
        info "No brew packages to install"
        return
    fi

    local pkg_total=${#packages[@]}
    log "Installing $pkg_total brew packages..."

    local pkg_count=0
    for pkg in "${packages[@]}"; do
        ((pkg_count++))
        tui_set_substep "Installing $pkg_count/$pkg_total: $pkg"

        if run_as_user "$BREW_PREFIX/bin/brew" list "$pkg" &>/dev/null; then
            info "$pkg already installed"
        else
            run_as_user "$BREW_PREFIX/bin/brew" install "$pkg" >> "$LOG_FILE" 2>&1 || warn "Failed to install: $pkg"
        fi
    done

    tui_set_substep ""
}

install_homebrew
install_packages

log "Homebrew setup complete!"
