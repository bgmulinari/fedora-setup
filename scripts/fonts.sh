#!/bin/bash
#
# Fonts Module - Install custom fonts
#

set -euo pipefail

log "Setting up fonts..."

# Font paths
FONTS_DIR="$ACTUAL_HOME/.local/share/fonts"
FONT_SUBDIR="$FONTS_DIR/JetBrainsMonoNerdFont"
DOWNLOAD_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"

# Install JetBrainsMono Nerd Font
install_jetbrains_font() {
    tui_set_substep "Installing JetBrainsMono Nerd Font..."

    # Check if already installed
    if [[ -d "$FONT_SUBDIR" ]] && ls "$FONT_SUBDIR"/*.ttf &>/dev/null; then
        info "JetBrainsMono Nerd Font already installed at $FONT_SUBDIR"
        return 0
    fi

    # Create font directory
    run_as_user mkdir -p "$FONT_SUBDIR"

    # Download and extract as actual user (avoids permission issues with temp file)
    log "Downloading JetBrainsMono Nerd Font..."
    if ! run_as_user bash -c "
        TMP_ZIP=\$(mktemp --suffix=.zip)
        trap 'rm -f \"\$TMP_ZIP\"' EXIT
        curl -fsSL '$DOWNLOAD_URL' -o \"\$TMP_ZIP\" && unzip -o \"\$TMP_ZIP\" -d '$FONT_SUBDIR'
    "; then
        error "Failed to download or extract font archive"
        return 1
    fi

    log "JetBrainsMono Nerd Font installed"
}

# Install Microsoft core fonts (Times New Roman, Arial, Verdana, etc.)
install_ms_fonts() {
    tui_set_substep "Installing Microsoft core fonts..."

    # Check if already installed
    if fc-list | grep -qi "times new roman"; then
        info "Microsoft fonts already installed"
        return 0
    fi

    # Install dependencies
    dnf install -y curl cabextract xorg-x11-font-utils fontconfig >> "$LOG_FILE" 2>&1

    # Install Microsoft core fonts
    log "Downloading Microsoft core fonts..."
    if rpm -i --nodigest --nosignature \
        https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm \
        >> "$LOG_FILE" 2>&1; then
        log "Microsoft fonts installed"
    else
        warn "Microsoft fonts installation failed (may already be installed)"
    fi
}

# Execute
install_jetbrains_font
install_ms_fonts

# Rebuild font cache
log "Rebuilding font cache..."
run_as_user fc-cache -fv "$FONTS_DIR"
fc-cache -fv >> "$LOG_FILE" 2>&1

log "Font installation complete!"
