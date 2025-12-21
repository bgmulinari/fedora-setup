# Dotfiles (Stow Packages)

This directory uses [GNU Stow](https://www.gnu.org/software/stow/) to manage dotfiles.

## How It Works

Each subdirectory is a "package" that mirrors your home directory structure:

```
dotfiles/
├── bash/
│   └── .bashrc              → ~/.bashrc
├── git/
│   └── .gitconfig           → ~/.gitconfig
├── nvim/
│   └── .config/
│       └── nvim/
│           └── init.lua     → ~/.config/nvim/init.lua
└── kde/
    └── .config/
        └── kdeglobals       → ~/.config/kdeglobals
```

## Adding Your Dotfiles

1. Create a package directory: `mkdir -p dotfiles/mypackage`
2. Mirror the path from your home directory:
   - If your file is at `~/.bashrc`, put it at `dotfiles/bash/.bashrc`
   - If your file is at `~/.config/nvim/init.lua`, put it at `dotfiles/nvim/.config/nvim/init.lua`
3. The setup script will automatically stow all packages

## Manual Stow Commands

```bash
# Link a single package
stow -v -d dotfiles -t ~ bash

# Unlink a package
stow -v -d dotfiles -t ~ -D bash

# Re-link after changes
stow -v -d dotfiles -t ~ --restow bash

# Adopt existing files (moves them into your dotfiles)
stow -v -d dotfiles -t ~ --adopt bash
```

## Tips

- Keep each logical group of configs in its own package (bash, nvim, git, etc.)
- This makes it easy to selectively deploy configs on different machines
- Use `--adopt` to pull existing configs into your dotfiles directory
