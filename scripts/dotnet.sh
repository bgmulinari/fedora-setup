#!/bin/bash
#
# .NET SDK Module - Install using Microsoft's official installer
#

log "Setting up .NET SDK..."

DOTNET_INSTALL_DIR="$ACTUAL_HOME/.dotnet"

# Show current version if installed
if [[ -x "$DOTNET_INSTALL_DIR/dotnet" ]]; then
    info "Current .NET SDK version: $("$DOTNET_INSTALL_DIR/dotnet" --version)"
fi

# Download and run installer as actual user (piped directly to bash)
log "Installing .NET SDK to $DOTNET_INSTALL_DIR..."
run_as_user bash -c 'curl -sSL https://dot.net/v1/dotnet-install.sh | bash' || {
    error "Failed to install .NET SDK"
    return 1
}

log ".NET SDK installation complete!"
