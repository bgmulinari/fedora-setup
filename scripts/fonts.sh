#!/bin/bash
#
# Fonts Module - Install custom fonts
#

set -euo pipefail

log "Setting up fonts..."

# Font paths
FONTS_DIR="$ACTUAL_HOME/.local/share/fonts"
JETBRAINS_FONT_DIR="$FONTS_DIR/JetBrainsMonoNerdFont"
JETBRAINS_DOWNLOAD_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
INTER_FONT_DIR="$FONTS_DIR/Inter"
INTER_DOWNLOAD_URL="https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip"

# Install JetBrainsMono Nerd Font
install_jetbrains_font() {
    tui_set_substep "Installing JetBrainsMono Nerd Font..."

    # Check if already installed
    if [[ -d "$JETBRAINS_FONT_DIR" ]] && ls "$JETBRAINS_FONT_DIR"/*.ttf &>/dev/null; then
        info "JetBrainsMono Nerd Font already installed at $JETBRAINS_FONT_DIR"
        return 0
    fi

    # Create font directory
    run_as_user mkdir -p "$JETBRAINS_FONT_DIR"

    # Download and extract as actual user (avoids permission issues with temp file)
    log "Downloading JetBrainsMono Nerd Font..."
    if ! run_as_user bash -c "
        TMP_ZIP=\$(mktemp --suffix=.zip)
        trap 'rm -f \"\$TMP_ZIP\"' EXIT
        curl -fsSL '$JETBRAINS_DOWNLOAD_URL' -o \"\$TMP_ZIP\" && unzip -o \"\$TMP_ZIP\" -d '$JETBRAINS_FONT_DIR'
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
    if rpm -q msttcore-fonts-installer &>/dev/null; then
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
        warn "Microsoft fonts installation failed"
    fi
}

# Install Inter font (Google Fonts)
install_inter_font() {
    tui_set_substep "Installing Inter font..."

    # Check if already installed
    if [[ -f "$INTER_FONT_DIR/InterVariable.ttf" ]]; then
        info "Inter font already installed at $INTER_FONT_DIR"
        return 0
    fi

    # Create font directory
    run_as_user mkdir -p "$INTER_FONT_DIR"

    # Download and extract only InterVariable.ttf
    log "Downloading Inter font..."
    if ! run_as_user bash -c "
        TMP_ZIP=\$(mktemp --suffix=.zip)
        trap 'rm -f \"\$TMP_ZIP\"' EXIT
        curl -fsSL '$INTER_DOWNLOAD_URL' -o \"\$TMP_ZIP\" && unzip -jo \"\$TMP_ZIP\" 'InterVariable.ttf' -d '$INTER_FONT_DIR'
    "; then
        error "Failed to download or extract Inter font"
        return 1
    fi

    log "Inter font installed"
}

# Execute
install_jetbrains_font
install_ms_fonts
install_inter_font

# Rebuild font cache
log "Rebuilding font cache..."
run_as_user fc-cache -f "$FONTS_DIR" >> "$LOG_FILE" 2>&1

log "Font installation complete!"
