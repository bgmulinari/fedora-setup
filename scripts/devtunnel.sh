#!/bin/bash
#
# Dev Tunnel Module - Install Microsoft Dev Tunnel CLI
#

log "Setting up Dev Tunnel CLI..."

DEVTUNNEL_BIN="$ACTUAL_HOME/.local/bin/devtunnel"

# Check if already installed
if [[ -x "$DEVTUNNEL_BIN" ]]; then
    info "Dev Tunnel CLI already installed at $DEVTUNNEL_BIN"
    return 0
fi

log "Installing Dev Tunnel CLI..."
run_as_user mkdir -p "$ACTUAL_HOME/.local/bin"
run_as_user curl -fsSL https://aka.ms/TunnelsCliDownload/linux-x64 -o "$DEVTUNNEL_BIN" || {
    error "Failed to download Dev Tunnel CLI"
    return 1
}
run_as_user chmod +x "$DEVTUNNEL_BIN"

log "Dev Tunnel CLI installation complete!"
