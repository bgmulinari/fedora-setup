#!/bin/bash
#
# Catppuccin Theme Module
# Installs Catppuccin Mocha (Blue accent) for KDE Plasma and GTK apps
#

set -euo pipefail

log "Installing Catppuccin themes..."

CATPPUCCIN_DIR="$ACTUAL_HOME/.local/share"
DEFAULT_WALLPAPER="SilentPeaks.jpg"  # Wallpaper to apply (from assets/wallpapers/)

# Install Catppuccin KDE theme (Plasma, color schemes, window decorations - NO cursor)
install_kde_theme() {
    local theme_dir="$CATPPUCCIN_DIR/plasma/look-and-feel/Catppuccin-Mocha-Blue"
    local color_file="$CATPPUCCIN_DIR/color-schemes/CatppuccinMochaBlue.colors"

    if [[ -d "$theme_dir" ]]; then
        log "Updating Catppuccin KDE theme..."
        # Remove existing files so upstream installer runs cleanly
        run_as_user rm -rf "$theme_dir"
        run_as_user rm -f "$color_file"
    else
        log "Installing Catppuccin KDE theme..."
    fi

    local tmp_dir="/tmp/catppuccin-kde-$$"

    run_as_user git clone --depth=1 https://github.com/catppuccin/kde "$tmp_dir"

    # Install components separately using debug modes to skip cursor
    # Args: Flavor=1(Mocha), Accent=13(Blue), WindowDec=1(Modern)
    run_as_user bash -c "cd '$tmp_dir' && ./install.sh 1 13 1 global"   # Global theme + splash

    # Color scheme: build then manually install (installer bug: debug mode doesn't install)
    run_as_user bash -c "cd '$tmp_dir' && ./install.sh 1 13 1 color"
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

    log "Installing VS Code Catppuccin extension..."
    run_as_user code --install-extension Catppuccin.catppuccin-vsc --force

    info "VS Code Catppuccin extension installed"
}

# Download btop Catppuccin theme
install_btop_theme() {
    local theme_dir="$ACTUAL_HOME/.config/btop/themes"
    local theme_file="$theme_dir/catppuccin_mocha.theme"

    log "Installing btop Catppuccin theme..."
    run_as_user mkdir -p "$theme_dir"
    run_as_user curl -fsSL -o "$theme_file" \
        "https://raw.githubusercontent.com/catppuccin/btop/main/themes/catppuccin_mocha.theme"

    info "btop Catppuccin theme installed"
}

# Install wallpapers (copies all from assets/wallpapers/)
install_wallpapers() {
    local src_dir="$SCRIPT_DIR/assets/wallpapers"
    local dest_dir="$ACTUAL_HOME/.local/share/wallpapers"

    if [[ ! -d "$src_dir" ]]; then
        info "No wallpapers directory found, skipping"
        return 0
    fi

    log "Installing wallpapers..."
    run_as_user mkdir -p "$dest_dir"

    local count=0
    for wallpaper in "$src_dir"/*; do
        [[ -f "$wallpaper" ]] || continue
        local filename
        filename=$(basename "$wallpaper")
        if [[ ! -f "$dest_dir/$filename" ]]; then
            run_as_user cp "$wallpaper" "$dest_dir/$filename"
            ((count++))
        fi
    done

    if [[ $count -gt 0 ]]; then
        info "$count wallpaper(s) installed"
    else
        info "Wallpapers already installed"
    fi
}

# Log JetBrains manual install instructions
log_jetbrains_info() {
    info "JetBrains IDEs: Install Catppuccin plugin via Settings > Plugins > Marketplace"
}

install_kde_theme
install_gtk_theme
install_vscode_theme
install_btop_theme
install_wallpapers

# Apply Catppuccin theme in KDE if available
apply_catppuccin_theme() {
    kde_available || return 0

    local theme_dir="$CATPPUCCIN_DIR/plasma/look-and-feel/Catppuccin-Mocha-Blue"
    if [[ -d "$theme_dir" ]]; then
        # Patch look-and-feel defaults to use Breeze window decorations instead of Catppuccin aurorae
        local defaults_file="$theme_dir/contents/defaults"
        if [[ -f "$defaults_file" ]]; then
            run_as_user sed -i \
                -e 's|^library=.*|library=org.kde.breeze|' \
                -e 's|^theme=.*aurorae.*|theme=Breeze|' \
                "$defaults_file"
        fi

        log "Applying Catppuccin Mocha Blue look-and-feel..."
        kde_apply_theme "Catppuccin-Mocha-Blue"
    fi

    # Apply GTK theme settings if GTK theme is installed
    local gtk_theme_dir="$CATPPUCCIN_DIR/themes/catppuccin-mocha-blue-standard+default"
    if [[ -d "$gtk_theme_dir" ]]; then
        log "Setting GTK theme..."
        kde_write --file gtk-3.0/settings.ini --group Settings --key gtk-theme-name "catppuccin-mocha-blue-standard+default"
        kde_write --file gtk-4.0/settings.ini --group Settings --key gtk-theme-name "catppuccin-mocha-blue-standard+default"
    fi

    # Apply wallpaper
    local wallpaper="$ACTUAL_HOME/.local/share/wallpapers/$DEFAULT_WALLPAPER"
    if [[ -f "$wallpaper" ]] && command -v plasma-apply-wallpaperimage &>/dev/null; then
        log "Applying wallpaper..."
        run_in_session plasma-apply-wallpaperimage "$wallpaper"
    fi
}

apply_catppuccin_theme
log_jetbrains_info

log "Catppuccin themes installed!"
