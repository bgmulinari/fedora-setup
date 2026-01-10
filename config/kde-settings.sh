#!/bin/bash
#
# KDE Plasma Settings
# Customize these settings for your preferences
# Uses kwriteconfig5 or kwriteconfig6 (auto-detected)
#

# ═══════════════════════════════════════════════════════════════
# APPEARANCE
# ═══════════════════════════════════════════════════════════════

# Global Theme / Look and Feel
# Available: org.kde.breeze.desktop, org.kde.breezedark.desktop,
#            org.fedoraproject.fedora.desktop, org.fedoraproject.fedoradark.desktop
run_lookandfeel "org.fedoraproject.fedoradark.desktop"

# Individual settings (only needed if NOT using look-and-feel above):
# run_kwrite --file kdeglobals --group General --key ColorScheme "BreezeLight"
# run_kwrite --file kdeglobals --group Icons --key Theme "breeze"
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
run_kwrite --file kdeglobals --group General --key fixed "JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"

# ═══════════════════════════════════════════════════════════════
# TERMINAL
# ═══════════════════════════════════════════════════════════════

# Default terminal emulator (both keys needed for full KDE integration)
run_kwrite --file kdeglobals --group General --key TerminalApplication "ghostty"
run_kwrite --file kdeglobals --group General --key TerminalService "com.mitchellh.ghostty.desktop"

# ═══════════════════════════════════════════════════════════════
# SHORTCUTS
# ═══════════════════════════════════════════════════════════════

# Example: Set Meta+E to open Dolphin
# run_kwrite --file kglobalshortcutsrc --group org.kde.dolphin.desktop --key _launch "Meta+E,Meta+E,Dolphin"

