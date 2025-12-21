#!/bin/bash
#
# Claude Code Module - Install Claude Code CLI
#

log "Setting up Claude Code..."

ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(getent passwd "$ACTUAL_USER" | cut -d: -f6)
CLAUDE_BIN="$ACTUAL_HOME/.local/bin/claude"

# Check if already installed
if [[ -x "$CLAUDE_BIN" ]]; then
    info "Claude Code already installed at $CLAUDE_BIN"
    return 0
fi

if [[ "$DRY_RUN" == true ]]; then
    info "[DRY RUN] Would download and run Claude Code installer"
    return 0
fi

log "Installing Claude Code..."
sudo -u "$ACTUAL_USER" bash -c 'curl -fsSL https://claude.ai/install.sh | bash' || {
    error "Failed to install Claude Code"
    return 1
}

log "Claude Code installation complete!"
