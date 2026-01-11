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

# Icon theme - Papirus Dark with breeze folders
run_kwrite --file kdeglobals --group Icons --key Theme "Papirus-Dark"

# Fixed-width font
run_kwrite --file kdeglobals --group General --key fixed "JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"

# Default terminal emulator (both keys needed for full KDE integration)
run_kwrite --file kdeglobals --group General --key TerminalApplication "ghostty"
run_kwrite --file kdeglobals --group General --key TerminalService "com.mitchellh.ghostty.desktop"

#
# Keybinds
#

# Unbind default Meta+[1-9] actions
run_kwrite --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 1" "none,Meta+1,Activate Task Manager Entry 1"
run_kwrite --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 2" "none,Meta+2,Activate Task Manager Entry 2"
run_kwrite --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 3" "none,Meta+3,Activate Task Manager Entry 3"
run_kwrite --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 4" "none,Meta+4,Activate Task Manager Entry 4"
run_kwrite --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 5" "none,Meta+5,Activate Task Manager Entry 5"
run_kwrite --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 6" "none,Meta+6,Activate Task Manager Entry 6"
run_kwrite --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 7" "none,Meta+7,Activate Task Manager Entry 7"
run_kwrite --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 8" "none,Meta+8,Activate Task Manager Entry 8"
run_kwrite --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 9" "none,Meta+9,Activate Task Manager Entry 9"

# Bind desktop switching Meta+[1-5] (default Ctrl+F[1-5])
run_kwrite --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 1" "Meta+1,Ctrl+F1,Switch to Desktop 1"
run_kwrite --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 2" "Meta+2,Ctrl+F2,Switch to Desktop 2"
run_kwrite --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 3" "Meta+3,Ctrl+F3,Switch to Desktop 3"
run_kwrite --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 4" "Meta+4,Ctrl+F4,Switch to Desktop 4"
run_kwrite --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 5" "Meta+5,Ctrl+F5,Switch to Desktop 5"

# Ghostty on Meta+Return
run_kwrite --file kglobalshortcutsrc --group services --group com.mitchellh.ghostty.desktop --key "_launch" "Meta+Return"
