#!/bin/bash
# Auto-install script for fedora-setup
# Usage: sh <(curl -L https://raw.githubusercontent.com/bgmulinari/fedora-setup/master/auto-install.sh)

set -euo pipefail

REPO_URL="https://github.com/bgmulinari/fedora-setup.git"
INSTALL_DIR="$HOME/fedora-setup"

GREEN='\033[0;32m'
NC='\033[0m'

# Ensure git is installed
if ! command -v git &> /dev/null; then
    echo -e "${GREEN}Installing git...${NC}"
    sudo dnf install -y git
fi

# Clone or update repository
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${GREEN}Updating existing installation...${NC}"
    cd "$INSTALL_DIR"
    git stash --quiet 2>/dev/null || true
    git pull --quiet
else
    echo -e "${GREEN}Cloning fedora-setup...${NC}"
    git clone --depth=1 "$REPO_URL" "$INSTALL_DIR"
fi

# Run setup
cd "$INSTALL_DIR"
chmod +x setup.sh
sudo ./setup.sh "$@"
