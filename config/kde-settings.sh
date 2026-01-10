#!/bin/bash
#
# KDE Plasma Settings
# Customize these settings for your preferences
# Uses kwriteconfig5 or kwriteconfig6 (auto-detected)
#

# Global Theme / Look and Feel
# Available: org.kde.breeze.desktop, org.kde.breezedark.desktop,
#            org.fedoraproject.fedora.desktop, org.fedoraproject.fedoradark.desktop
run_lookandfeel "org.fedoraproject.fedoradark.desktop"

# Fixed-width font
run_kwrite --file kdeglobals --group General --key fixed "JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"

# Default terminal emulator (both keys needed for full KDE integration)
run_kwrite --file kdeglobals --group General --key TerminalApplication "ghostty"
run_kwrite --file kdeglobals --group General --key TerminalService "com.mitchellh.ghostty.desktop"
