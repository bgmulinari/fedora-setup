#!/bin/bash
#
# KDE Plasma Settings
# Customize these settings for your preferences
# Uses kwriteconfig5 or kwriteconfig6 (auto-detected)
#

# Global Theme / Look and Feel - Catppuccin Mocha Blue
run_lookandfeel "Catppuccin-Mocha-Blue"

# GTK theme (for GTK apps running in KDE)
run_kwrite --file gtk-3.0/settings.ini --group Settings --key gtk-theme-name "catppuccin-mocha-blue-standard+default"
run_kwrite --file gtk-4.0/settings.ini --group Settings --key gtk-theme-name "catppuccin-mocha-blue-standard+default"

# Fixed-width font
run_kwrite --file kdeglobals --group General --key fixed "JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"

# Default terminal emulator (both keys needed for full KDE integration)
run_kwrite --file kdeglobals --group General --key TerminalApplication "ghostty"
run_kwrite --file kdeglobals --group General --key TerminalService "com.mitchellh.ghostty.desktop"
