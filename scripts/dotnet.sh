#!/bin/bash
#
# .NET SDK Module - Install using Microsoft's official installer
#

log "Setting up .NET SDK..."

ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(getent passwd "$ACTUAL_USER" | cut -d: -f6)
DOTNET_INSTALL_DIR="$ACTUAL_HOME/.dotnet"

# Show current version if installed
if [[ -x "$DOTNET_INSTALL_DIR/dotnet" ]]; then
    info "Current .NET SDK version: $("$DOTNET_INSTALL_DIR/dotnet" --version)"
fi

if [[ "$DRY_RUN" == true ]]; then
    info "[DRY RUN] Would download and run dotnet-install.sh"
    info "[DRY RUN] Would install .NET SDK to $DOTNET_INSTALL_DIR"
    return 0
fi

# Download and run installer as actual user (piped directly to bash)
log "Installing .NET SDK to $DOTNET_INSTALL_DIR..."
sudo -u "$ACTUAL_USER" bash -c 'curl -sSL https://dot.net/v1/dotnet-install.sh | bash' || {
    error "Failed to install .NET SDK"
    return 1
}

log ".NET SDK installation complete!"
