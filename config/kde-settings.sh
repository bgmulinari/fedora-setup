#!/bin/bash
#
# KDE Plasma Settings
# Customize these settings for your preferences
# Uses kwriteconfig5 or kwriteconfig6 (auto-detected)
#

# ═══════════════════════════════════════════════════════════════
# APPEARANCE
# ═══════════════════════════════════════════════════════════════

# Color scheme (e.g., "BreezeDark", "BreezeLight", "BreezeClassic")
# run_kwrite --file kdeglobals --group General --key ColorScheme "BreezeDark"

# Icon theme (e.g., "breeze-dark", "breeze", "Papirus-Dark")
# run_kwrite --file kdeglobals --group Icons --key Theme "breeze-dark"

# Cursor theme (e.g., "breeze_cursors", "Breeze_Snow")
# run_kwrite --file kcminputrc --group Mouse --key cursorTheme "breeze_cursors"

# ═══════════════════════════════════════════════════════════════
# DESKTOP BEHAVIOR
# ═══════════════════════════════════════════════════════════════

# Single-click to open files (false = double-click)
# run_kwrite --file kdeglobals --group KDE --key SingleClick "false"

# ═══════════════════════════════════════════════════════════════
# FONTS
# ═══════════════════════════════════════════════════════════════

# General font
# run_kwrite --file kdeglobals --group General --key font "Noto Sans,10,-1,5,50,0,0,0,0,0"

# Fixed-width font
# run_kwrite --file kdeglobals --group General --key fixed "JetBrains Mono,10,-1,5,50,0,0,0,0,0"

# ═══════════════════════════════════════════════════════════════
# KONSOLE
# ═══════════════════════════════════════════════════════════════

# Default Konsole profile is set via ~/.local/share/konsole/ profiles

# ═══════════════════════════════════════════════════════════════
# SHORTCUTS
# ═══════════════════════════════════════════════════════════════

# Example: Set Meta+E to open Dolphin
# run_kwrite --file kglobalshortcutsrc --group org.kde.dolphin.desktop --key _launch "Meta+E,Meta+E,Dolphin"

