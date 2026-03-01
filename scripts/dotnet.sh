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

install_tools() {
    local tools_file="$SCRIPT_DIR/packages/dotnet-tools.txt"

    if [[ ! -f "$tools_file" ]]; then
        info "No dotnet tools file found, skipping"
        return
    fi

    local tools=()
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        line=$(echo "$line" | xargs)
        tools+=("$line")
    done < "$tools_file"

    if [[ ${#tools[@]} -eq 0 ]]; then
        info "No dotnet tools to install"
        return
    fi

    local tool_total=${#tools[@]}
    log "Installing $tool_total .NET global tools..."

    local tool_count=0
    for tool in "${tools[@]}"; do
        ((++tool_count))
        tui_set_substep "Installing $tool_count/$tool_total: $tool"
        run_as_user "$DOTNET_INSTALL_DIR/dotnet" tool install -g "$tool" >> "$LOG_FILE" 2>&1 || warn "Failed to install: $tool"
    done

    tui_set_substep ""
}

install_tools

log ".NET SDK installation complete!"
