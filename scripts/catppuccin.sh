#!/bin/bash
#
# Catppuccin Theme Module
# Installs Catppuccin Mocha (Blue accent) for KDE Plasma and GTK apps
#

set -euo pipefail

log "Installing Catppuccin themes..."

CATPPUCCIN_DIR="$ACTUAL_HOME/.local/share"

# Install Catppuccin KDE theme (Plasma, color schemes, window decorations - NO cursor)
install_kde_theme() {
    if [[ -d "$CATPPUCCIN_DIR/plasma/look-and-feel/Catppuccin-Mocha-Blue" ]]; then
        info "Catppuccin KDE theme already installed"
        return 0
    fi

    log "Installing Catppuccin KDE theme..."
    local tmp_dir="/tmp/catppuccin-kde-$$"

    run_as_user git clone --depth=1 https://github.com/catppuccin/kde "$tmp_dir"

    # Install components separately using debug modes to skip cursor
    # Args: Flavor=1(Mocha), Accent=13(Blue), WindowDec=2(Classic)
    run_as_user bash -c "cd '$tmp_dir' && ./install.sh 1 13 2 global"   # Global theme + splash
    run_as_user bash -c "cd '$tmp_dir' && ./install.sh 1 13 2 aurorae"  # Window decorations (Classic)

    # Color scheme: build then manually install (installer bug: debug mode doesn't install)
    run_as_user bash -c "cd '$tmp_dir' && ./install.sh 1 13 2 color"
    run_as_user mkdir -p "$CATPPUCCIN_DIR/color-schemes"
    run_as_user bash -c "mv '$tmp_dir/dist/CatppuccinMochaBlue.colors' '$CATPPUCCIN_DIR/color-schemes/'"
    # Note: cursor mode intentionally skipped

    rm -rf "$tmp_dir"

    info "Catppuccin KDE theme installed"
}

# Install Catppuccin GTK theme (for GTK apps running in KDE)
# Downloads pre-built theme from releases (install.py has Python 3.14 compatibility issues)
install_gtk_theme() {
    local theme_dir="$CATPPUCCIN_DIR/themes"
    local theme_name="catppuccin-mocha-blue-standard+default"

    if [[ -d "$theme_dir/$theme_name" ]]; then
        info "Catppuccin GTK theme already installed"
        return 0
    fi

    log "Installing Catppuccin GTK theme..."
    run_as_user mkdir -p "$theme_dir"

    local tmp_file="/tmp/catppuccin-gtk-$$.zip"
    local download_url="https://github.com/catppuccin/gtk/releases/download/v1.0.3/catppuccin-mocha-blue-standard%2Bdefault.zip"

    run_as_user curl -fsSL -o "$tmp_file" "$download_url"
    run_as_user unzip -q "$tmp_file" -d "$theme_dir"
    rm -f "$tmp_file"

    info "Catppuccin GTK theme installed"
}

# Install VS Code Catppuccin extension
install_vscode_theme() {
    if ! command -v code &>/dev/null; then
        info "VS Code not installed, skipping theme"
        return 0
    fi

    # Check if extension already installed
    if run_as_user code --list-extensions 2>/dev/null | grep -qi "catppuccin.catppuccin-vsc"; then
        info "VS Code Catppuccin extension already installed"
        return 0
    fi

    log "Installing VS Code Catppuccin extension..."
    run_as_user code --install-extension Catppuccin.catppuccin-vsc --force

    info "VS Code Catppuccin extension installed"
}

# Download btop Catppuccin theme
install_btop_theme() {
    local theme_dir="$ACTUAL_HOME/.config/btop/themes"
    local theme_file="$theme_dir/catppuccin_mocha.theme"

    if [[ -f "$theme_file" ]]; then
        info "btop Catppuccin theme already installed"
        return 0
    fi

    log "Installing btop Catppuccin theme..."
    run_as_user mkdir -p "$theme_dir"
    run_as_user curl -fsSL -o "$theme_file" \
        "https://raw.githubusercontent.com/catppuccin/btop/main/themes/catppuccin_mocha.theme"

    info "btop Catppuccin theme installed"
}

# Log JetBrains manual install instructions
log_jetbrains_info() {
    info "JetBrains IDEs: Install Catppuccin plugin via Settings > Plugins > Marketplace"
}

install_kde_theme
install_gtk_theme
install_vscode_theme
install_btop_theme
log_jetbrains_info

log "Catppuccin themes installed!"
