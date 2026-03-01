#!/bin/bash
#
# JetBrains Toolbox Module - Install JetBrains Toolbox App
#

log "Setting up JetBrains Toolbox..."

# Installation paths
TOOLBOX_DIR="$ACTUAL_HOME/.local/share/JetBrains/Toolbox"
TOOLBOX_BIN="$TOOLBOX_DIR/bin/jetbrains-toolbox"
LOCAL_BIN="$ACTUAL_HOME/.local/bin"
TOOLBOX_SYMLINK="$LOCAL_BIN/jetbrains-toolbox"

# JetBrains API for latest release
RELEASES_API="https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release"

# Check if already installed
if [[ -x "$TOOLBOX_BIN" ]]; then
    info "JetBrains Toolbox already installed at $TOOLBOX_DIR"
    return 0
fi

# Fetch download URL from API
log "Fetching latest JetBrains Toolbox version..."
API_RESPONSE=$(curl -fsSL "$RELEASES_API") || {
    error "Failed to fetch JetBrains API"
    return 1
}

# Parse download URL (Linux tar.gz link)
DOWNLOAD_URL=$(echo "$API_RESPONSE" | grep -Po '"linux":\s*\{[^}]*"link":\s*"\K[^"]+' | head -1)

if [[ -z "$DOWNLOAD_URL" ]]; then
    error "Failed to parse download URL from API response"
    return 1
fi

# Extract version for logging
VERSION=$(echo "$API_RESPONSE" | grep -Po '"version":\s*"\K[^"]+' | head -1)
info "Latest version: $VERSION"
info "Download URL: $DOWNLOAD_URL"

# Create directories
run_as_user mkdir -p "$TOOLBOX_DIR"
run_as_user mkdir -p "$LOCAL_BIN"

# Download and extract in one step
log "Downloading and extracting JetBrains Toolbox..."
if ! run_as_user bash -c "curl -fsSL '$DOWNLOAD_URL' | tar -xzf - -C '$TOOLBOX_DIR' --strip-components=1"; then
    error "Failed to download or extract JetBrains Toolbox"
    return 1
fi

# Create symlink
if [[ -L "$TOOLBOX_SYMLINK" ]]; then
    rm -f "$TOOLBOX_SYMLINK"
fi
run_as_user ln -s "$TOOLBOX_BIN" "$TOOLBOX_SYMLINK"
info "Created symlink: $TOOLBOX_SYMLINK"

# Launch Toolbox in background to initialize .desktop file
log "Launching Toolbox to initialize desktop integration..."
run_as_user bash -c "nohup '$TOOLBOX_BIN' &>/dev/null &"
sleep 2
info "Toolbox launched in background"
info "Desktop entry will be created at ~/.local/share/applications/"

log "JetBrains Toolbox installation complete!"
