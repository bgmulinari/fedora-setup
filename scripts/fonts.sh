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

# Check if already installed
if [[ -d "$FONT_SUBDIR" ]] && ls "$FONT_SUBDIR"/*.ttf &>/dev/null; then
    info "JetBrainsMono Nerd Font already installed at $FONT_SUBDIR"
    return 0
fi

# Dry-run mode
if [[ "$DRY_RUN" == true ]]; then
    info "[DRY RUN] Would download JetBrainsMono.zip from GitHub"
    info "[DRY RUN] Would extract to $FONT_SUBDIR"
    info "[DRY RUN] Would rebuild font cache"
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

# Rebuild font cache
log "Rebuilding font cache..."
run_as_user fc-cache -fv "$FONTS_DIR"

log "Font installation complete!"
