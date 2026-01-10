#!/bin/bash
#
# Repository Setup Module
# Enables RPM Fusion, Flathub, and COPR repositories
#

log "Setting up repositories..."

COPR_FILE="$SCRIPT_DIR/packages/copr-repos.txt"

# Enable RPM Fusion (Free and Non-Free)
enable_rpmfusion() {
    log "Enabling RPM Fusion repositories..."

    # Check if already enabled
    if dnf repolist | grep -q "rpmfusion-free"; then
        info "RPM Fusion Free already enabled"
    else
        dnf install -y \
            "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
    fi

    if dnf repolist | grep -q "rpmfusion-nonfree"; then
        info "RPM Fusion Non-Free already enabled"
    else
        dnf install -y \
            "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
    fi

    # Enable additional repos for appstream metadata
    dnf config-manager setopt fedora-cisco-openh264.enabled=1 || true

    log "RPM Fusion enabled successfully"
}

# Enable Flathub for Flatpak
enable_flathub() {
    log "Enabling Flathub repository..."

    # Ensure Flatpak is installed
    if ! command -v flatpak &> /dev/null; then
        dnf install -y flatpak
    fi

    # Add Flathub remote
    if flatpak remotes | grep -q "flathub"; then
        info "Flathub already configured"
    else
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        log "Flathub enabled successfully"
    fi
}

# Enable COPR repositories from file
enable_copr_repos() {
    if [[ ! -f "$COPR_FILE" ]]; then
        info "No COPR repos file found, skipping"
        return
    fi

    log "Enabling COPR repositories..."

    while IFS= read -r repo || [[ -n "$repo" ]]; do
        # Skip empty lines and comments
        [[ -z "$repo" || "$repo" =~ ^[[:space:]]*# ]] && continue

        # Trim whitespace
        repo=$(echo "$repo" | xargs)

        if dnf copr list | grep -q "$repo"; then
            info "COPR $repo already enabled"
        else
            dnf copr enable -y "$repo"
            log "Enabled COPR: $repo"
        fi
    done < "$COPR_FILE"
}

# Apply custom DNF configuration
apply_dnf_config() {
    local custom_conf="$SCRIPT_DIR/config/dnf.conf"

    if [[ ! -f "$custom_conf" ]]; then
        info "No custom DNF config found, skipping"
        return
    fi

    log "Applying custom DNF configuration..."

    # Backup existing config
    if [[ -f /etc/dnf/dnf.conf ]] && [[ ! -f /etc/dnf/dnf.conf.backup ]]; then
        cp /etc/dnf/dnf.conf /etc/dnf/dnf.conf.backup
    fi

    # Append custom settings (avoid duplicates)
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# || "$line" =~ ^\[.*\]$ ]] && continue

        key=$(echo "$line" | cut -d'=' -f1)
        if ! grep -q "^$key=" /etc/dnf/dnf.conf 2>/dev/null; then
            echo "$line" >> /etc/dnf/dnf.conf
            info "Added DNF setting: $line"
        fi
    done < "$custom_conf"
}

# Run system update after repos are configured
run_update() {
    log "Running system update..."

    dnf update -y
    log "System update complete"
}

# Enable Visual Studio Code repository
enable_vscode_repo() {
    log "Enabling Visual Studio Code repository..."

    if [[ -f /etc/yum.repos.d/vscode.repo ]]; then
        info "VS Code repository already configured"
        return
    fi

    rpm --import https://packages.microsoft.com/keys/microsoft.asc

    cat > /etc/yum.repos.d/vscode.repo << 'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

    log "VS Code repository enabled"
}

# Execute
apply_dnf_config
enable_rpmfusion
enable_flathub
enable_copr_repos
enable_vscode_repo
run_update

log "Repository setup complete!"
