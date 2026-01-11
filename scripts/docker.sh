#!/bin/bash
#
# Docker Engine Installation Module
# Installs Docker CE from official Docker repository
#

log "Setting up Docker..."

# Remove conflicting packages
remove_conflicting_packages() {
    log "Removing conflicting packages..."

    local conflicts=(
        docker docker-client docker-client-latest docker-common
        docker-latest docker-latest-logrotate docker-logrotate
        docker-selinux docker-engine-selinux docker-engine
    )

    dnf remove -y "${conflicts[@]}" 2>/dev/null || true
}

# Add Docker repository
add_docker_repo() {
    log "Adding Docker repository..."

    if dnf repolist | grep -q "docker-ce"; then
        info "Docker repository already configured"
        return
    fi

    dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
    log "Docker repository added"
}

# Install Docker packages
install_docker() {
    log "Installing Docker Engine..."

    local packages=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)

    if command -v docker &>/dev/null && docker --version &>/dev/null; then
        info "Docker already installed: $(docker --version)"
        return
    fi

    dnf install -y "${packages[@]}"
    log "Docker installed successfully"
}

# Enable and start Docker service
enable_docker_service() {
    log "Enabling Docker service..."

    # Reload systemd to recognize new unit files
    systemctl daemon-reload

    if systemctl is-enabled docker &>/dev/null; then
        info "Docker service already enabled"
    else
        systemctl enable --now docker
        log "Docker service enabled and started"
    fi
}

# Add user to docker group
add_user_to_docker_group() {
    if [[ -z "$ACTUAL_USER" || "$ACTUAL_USER" == "root" ]]; then
        warn "Cannot determine non-root user for docker group"
        return
    fi

    log "Adding $ACTUAL_USER to docker group..."

    if id -nG "$ACTUAL_USER" | grep -qw docker; then
        info "User $ACTUAL_USER already in docker group"
        return
    fi

    usermod -aG docker "$ACTUAL_USER"
    info "Added $ACTUAL_USER to docker group (re-login required)"
}

# Execute
remove_conflicting_packages
add_docker_repo
install_docker
enable_docker_service
add_user_to_docker_group

log "Docker setup complete!"
