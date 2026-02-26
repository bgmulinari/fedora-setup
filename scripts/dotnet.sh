#!/bin/bash
#
# .NET SDK Module - Install using Microsoft's official installer
#

log "Setting up .NET SDK..."

DOTNET_INSTALL_DIR="$ACTUAL_HOME/.dotnet"

# Show current versions if installed
if [[ -x "$DOTNET_INSTALL_DIR/dotnet" ]]; then
    info "Current .NET SDKs: $("$DOTNET_INSTALL_DIR/dotnet" --list-sdks 2>/dev/null | paste -sd ', ')"
fi

# Install/update .NET SDKs
run_as_user "$SCRIPT_DIR/dotfiles/bin/.local/bin/dotnet-update" "$DOTNET_INSTALL_DIR" || {
    error "Failed to install .NET SDK"
    return 1
}

# Show installed SDKs
if [[ -x "$DOTNET_INSTALL_DIR/dotnet" ]]; then
    info "Installed SDKs: $("$DOTNET_INSTALL_DIR/dotnet" --list-sdks 2>/dev/null | paste -sd ', ')"
fi

log ".NET SDK installation complete!"
