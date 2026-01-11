#!/bin/bash
#
# KDE Helper Library
# Provides kwriteconfig detection and wrapper functions for all modules
#

# ─────────────────────────────────────────────────────────────────────────────
# KDE Tool Detection (runs once when sourced)
# ─────────────────────────────────────────────────────────────────────────────

# Detect kwriteconfig version (KDE 6 vs 5)
if command -v kwriteconfig6 &>/dev/null; then
    KDE_KWRITE="kwriteconfig6"
elif command -v kwriteconfig5 &>/dev/null; then
    KDE_KWRITE="kwriteconfig5"
else
    KDE_KWRITE=""
fi

# Detect look-and-feel tool (KDE 6 vs 5)
if command -v plasma-apply-lookandfeel &>/dev/null; then
    KDE_LOOKANDFEEL="plasma-apply-lookandfeel"
elif command -v lookandfeeltool &>/dev/null; then
    KDE_LOOKANDFEEL="lookandfeeltool"
else
    KDE_LOOKANDFEEL=""
fi

# ─────────────────────────────────────────────────────────────────────────────
# KDE Helper Functions
# ─────────────────────────────────────────────────────────────────────────────

# Check if KDE tools are available
kde_available() {
    [[ -n "$KDE_KWRITE" ]]
}

# Apply a kwriteconfig setting (no-op if KDE not available)
kde_write() {
    if [[ -z "$KDE_KWRITE" ]]; then
        return 0
    fi
    run_in_session "$KDE_KWRITE" "$@"
}

# Apply look-and-feel theme
kde_apply_theme() {
    local theme="$1"
    if [[ -z "$KDE_LOOKANDFEEL" ]]; then
        warn "No look-and-feel tool found, cannot apply theme: $theme"
        return 1
    fi
    run_in_session "$KDE_LOOKANDFEEL" -a "$theme"
}

# ─────────────────────────────────────────────────────────────────────────────
# Export for child scripts
# ─────────────────────────────────────────────────────────────────────────────

export KDE_KWRITE KDE_LOOKANDFEEL
export -f kde_available kde_write kde_apply_theme
