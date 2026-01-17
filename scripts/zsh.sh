#!/bin/bash
#
# Zsh Module - Install Oh My Zsh, plugins, and set as default shell
#

log "Setting up Zsh with Oh My Zsh..."

OH_MY_ZSH_DIR="$ACTUAL_HOME/.oh-my-zsh"
CUSTOM_PLUGINS_DIR="$OH_MY_ZSH_DIR/custom/plugins"
ZSH_DIR="$ACTUAL_HOME/.zsh"

# Install Oh My Zsh (unattended, skip chsh)
install_oh_my_zsh() {
    if [[ -d "$OH_MY_ZSH_DIR" ]]; then
        info "Oh My Zsh already installed"
        return 0
    fi

    log "Installing Oh My Zsh..."
    run_as_user bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended' || {
        error "Failed to install Oh My Zsh"
        return 1
    }
}

# Install zsh plugins
install_plugins() {
    log "Installing Zsh plugins..."

    # zsh-autosuggestions
    local autosuggestions_dir="$CUSTOM_PLUGINS_DIR/zsh-autosuggestions"
    if [[ -d "$autosuggestions_dir" ]]; then
        info "zsh-autosuggestions already installed"
    else
        run_as_user git clone https://github.com/zsh-users/zsh-autosuggestions "$autosuggestions_dir" || {
            error "Failed to install zsh-autosuggestions"
            return 1
        }
    fi

    # zsh-syntax-highlighting
    local syntax_highlighting_dir="$CUSTOM_PLUGINS_DIR/zsh-syntax-highlighting"
    if [[ -d "$syntax_highlighting_dir" ]]; then
        info "zsh-syntax-highlighting already installed"
    else
        run_as_user git clone https://github.com/zsh-users/zsh-syntax-highlighting "$syntax_highlighting_dir" || {
            error "Failed to install zsh-syntax-highlighting"
            return 1
        }
    fi
}

# Install Catppuccin Mocha theme for zsh-syntax-highlighting
install_catppuccin_theme() {
    log "Installing Catppuccin Mocha syntax highlighting theme..."

    run_as_user mkdir -p "$ZSH_DIR"

    local theme_url="https://raw.githubusercontent.com/catppuccin/zsh-syntax-highlighting/main/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh"
    local theme_file="$ZSH_DIR/catppuccin_mocha-zsh-syntax-highlighting.zsh"

    run_as_user curl -fsSL "$theme_url" -o "$theme_file" || {
        error "Failed to download Catppuccin theme"
        return 1
    }
}

# Ensure /bin/zsh is in /etc/shells
ensure_valid_shell() {
    if ! grep -q "^/bin/zsh$" /etc/shells 2>/dev/null; then
        log "Adding /bin/zsh to /etc/shells..."
        echo "/bin/zsh" >> /etc/shells
    fi
}

# Change default shell to zsh
change_default_shell() {
    local current_shell
    current_shell=$(getent passwd "$ACTUAL_USER" | cut -d: -f7)

    if [[ "$current_shell" == "/bin/zsh" ]]; then
        info "Default shell already set to zsh"
        return 0
    fi

    log "Changing default shell to zsh for $ACTUAL_USER..."
    chsh -s /bin/zsh "$ACTUAL_USER" || {
        error "Failed to change default shell"
        return 1
    }
}

# Run installation steps
install_oh_my_zsh
install_plugins
install_catppuccin_theme
ensure_valid_shell
change_default_shell

log "Zsh setup complete!"
