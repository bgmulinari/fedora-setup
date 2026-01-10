#!/bin/bash
#
# Dotfiles Module - Using GNU Stow
# Manages dotfiles symlinks using stow
#

log "Setting up dotfiles with GNU Stow..."

DOTFILES_DIR="$SCRIPT_DIR/dotfiles"
TARGET_HOME="$ACTUAL_HOME"

# Ensure stow is installed
install_stow() {
    if command -v stow &> /dev/null; then
        info "GNU Stow is already installed"
        return 0
    fi

    log "Installing GNU Stow..."
    dnf install -y stow || {
        error "Failed to install stow"
        return 1
    }
}

# Run stow as the actual user
run_stow() {
    run_as_user stow "$@"
}

# Pre-create parent directories for a package to avoid directory-level symlinks
# This ensures stow creates file-level symlinks instead of symlinking entire directories
precreate_dirs() {
    local package_dir="$1"

    # Find top-level directories in the package and create them in target
    for item in "$package_dir"/*/; do
        [[ -d "$item" ]] || continue
        local rel_path="${item#$package_dir/}"
        rel_path="${rel_path%/}"
        local target_path="$TARGET_HOME/$rel_path"

        if [[ ! -e "$target_path" ]]; then
            run_as_user mkdir -p "$target_path"
        fi
    done
}

# Stow a single package
stow_package() {
    local package="$1"
    local package_dir="$DOTFILES_DIR/$package"

    if [[ ! -d "$package_dir" ]]; then
        warn "Package directory not found: $package_dir"
        return 1
    fi

    # Skip if package directory is empty
    if [[ -z "$(ls -A "$package_dir" 2>/dev/null)" ]]; then
        info "Skipping empty package: $package"
        return 0
    fi

    # Pre-create parent directories to ensure file-level symlinks
    precreate_dirs "$package_dir"

    info "Stowing package: $package"
    # Use --restow to handle updates, --adopt to take ownership of existing files
    if ! run_stow -v -d "$DOTFILES_DIR" -t "$TARGET_HOME" --restow "$package" 2>&1; then
        warn "Conflict detected for $package. Trying with --adopt..."
        run_stow -v -d "$DOTFILES_DIR" -t "$TARGET_HOME" --adopt --restow "$package" || {
            error "Failed to stow package: $package"
            return 1
        }
    fi
}

# Unstow a package (for cleanup)
unstow_package() {
    local package="$1"

    info "Unstowing package: $package"
    run_stow -v -d "$DOTFILES_DIR" -t "$TARGET_HOME" -D "$package" || {
        warn "Failed to unstow package: $package"
    }
}

# Main function to stow all packages
stow_all_packages() {
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        warn "Dotfiles directory not found: $DOTFILES_DIR"
        info "Create package directories in $DOTFILES_DIR to manage dotfiles"
        info "Example structure:"
        info "  dotfiles/bash/.bashrc"
        info "  dotfiles/nvim/.config/nvim/init.lua"
        info "  dotfiles/git/.gitconfig"
        return
    fi

    # Find all package directories (direct subdirectories of dotfiles/)
    local packages=()
    for dir in "$DOTFILES_DIR"/*/; do
        [[ -d "$dir" ]] || continue
        local pkg_name
        pkg_name=$(basename "$dir")
        # Skip hidden directories and special files
        [[ "$pkg_name" == .* ]] && continue
        packages+=("$pkg_name")
    done

    if [[ ${#packages[@]} -eq 0 ]]; then
        info "No stow packages found in $DOTFILES_DIR"
        info "Create subdirectories for each package you want to manage"
        return
    fi

    log "Found ${#packages[@]} stow package(s): ${packages[*]}"

    for package in "${packages[@]}"; do
        stow_package "$package"
    done
}

# Execute
install_stow
stow_all_packages

log "Dotfiles setup complete!"
