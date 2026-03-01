#!/bin/bash
#
# TUI Library for Fedora Setup Script
# Provides styled terminal output using gum (charmbracelet/gum)
#

# ─────────────────────────────────────────────────────────────────────────────
# TUI State Variables
# ─────────────────────────────────────────────────────────────────────────────

# Module status: pending, running, done, skipped, error
declare -A TUI_MODULE_STATUS=()

# ─────────────────────────────────────────────────────────────────────────────
# Core TUI Functions
# ─────────────────────────────────────────────────────────────────────────────

tui_init() {
    # Install gum if not present
    if ! command -v gum &>/dev/null; then
        if command -v dnf &>/dev/null; then
            dnf install -y gum &>/dev/null || true
        fi
    fi

    # Verify gum is available
    if ! command -v gum &>/dev/null; then
        error "gum is required but could not be installed"
        exit 1
    fi

    # Initialize module status
    local module
    for module in $ALL_MODULES; do
        TUI_MODULE_STATUS["$module"]="pending"
    done
}

tui_cleanup() {
    : # No-op (nothing to restore)
}

# ─────────────────────────────────────────────────────────────────────────────
# Display Functions
# ─────────────────────────────────────────────────────────────────────────────

tui_banner() {
    clear
    local title repo warning banner
    title=$(gum style --bold --foreground 4 "$SCRIPT_TITLE")
    repo=$(gum style --bold --foreground "" "https://github.com/bgmulinari/fedora-setup")
    warning=$(gum style --foreground 11 "⚠ This setup may overwrite existing configuration files! ⚠")
    banner=$(printf "%s\n%s\n\\n%s" "$title" "$repo" "$warning")
    gum style \
        --border double --border-foreground 4 \
        --align center --width 70 --padding "1 2" \
        "$banner"
}

# Build a labeled option string for the module picker (reads from MODULE_DESC in setup.sh)
_tui_module_label() {
    printf "%-12s %s" "$1" "${MODULE_DESC[$1]}"
}

tui_select_modules() {
    # Build labeled options and pre-selected list
    local module options=() selected_labels=()
    for module in $ALL_MODULES; do
        local label
        label=$(_tui_module_label "$module")
        options+=("$label")
        if should_run_module "$module"; then
            selected_labels+=("$label")
        fi
    done

    local selected_csv
    selected_csv=$(IFS=,; echo "${selected_labels[*]}")

    local chosen
    chosen=$(gum choose --no-limit \
        --header $'\nSelect modules to run:' \
        --header.foreground "" \
        --height 999 \
        --selected "$selected_csv" \
        --selected.foreground 2 \
        --cursor.foreground "" \
        "${options[@]}") || return 1

    [[ -z "$chosen" ]] && return 1

    # Extract module names (first word of each line)
    ONLY_MODULES=$(echo "$chosen" | awk '{print $1}' | paste -sd,)
    return 0
}

tui_show_plan() {
    local modules_run="$1"
    local modules_skip="$2"

    echo ""
    gum style --bold --foreground "" "Modules to run:"
    local module
    for module in $modules_run; do
        echo "  $(gum style --foreground 2 '+') $module"
    done

    if [[ -n "${modules_skip// }" ]]; then
        echo ""
        gum style --bold --foreground "" "Modules to skip:"
        for module in $modules_skip; do
            echo "  $(gum style --foreground 3 '-') $module"
        done
    fi

    echo ""
}

tui_confirm() {
    local prompt="$1"
    gum confirm --prompt.foreground "" --selected.background 12 "$prompt"
}

# ─────────────────────────────────────────────────────────────────────────────
# Module Progress Functions
# ─────────────────────────────────────────────────────────────────────────────

tui_start_module() {
    local module="$1"
    TUI_MODULE_STATUS["$module"]="running"
}

tui_run_module() {
    local module="$1"
    local script="$2"

    gum spin --spinner points --spinner.foreground 2 --title.foreground 4 --title "$module" -- \
        bash -c 'set -euo pipefail; exec 2>>"$LOG_FILE"; source "$1"' _ "$script"
    return $?
}

tui_end_module() {
    local module="$1"
    local status="${2:-done}"
    TUI_MODULE_STATUS["$module"]="$status"

    if [[ "$status" == "done" ]]; then
        echo "$(gum style --foreground 2 ' ✓') $module"
    else
        echo "$(gum style --foreground 1 ' ✗') $module"
    fi
}

tui_skip_module() {
    local module="$1"
    TUI_MODULE_STATUS["$module"]="skipped"

    gum style --faint "○ $module (skipped)"
}

tui_set_substep() {
    if [[ -n "${LOG_FILE:-}" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUBSTEP: $1" >> "$LOG_FILE"
    fi
}

tui_summary() {
    local succeeded=0 failed=0 skipped=0
    local module
    for module in $ALL_MODULES; do
        case "${TUI_MODULE_STATUS[$module]:-pending}" in
            done) ((++succeeded)) ;;
            error) ((++failed)) ;;
            skipped) ((++skipped)) ;;
        esac
    done

    echo ""
    local counts=""
    [[ $succeeded -gt 0 ]] && counts+="$(gum style --bold --foreground 2 '✓') $succeeded succeeded"
    [[ $failed -gt 0 ]] && { [[ -n "$counts" ]] && counts+="  "; counts+="$(gum style --bold --foreground 1 '✗') $failed failed"; }
    [[ $skipped -gt 0 ]] && { [[ -n "$counts" ]] && counts+="  "; counts+="$(gum style --bold --foreground 3 '○') $skipped skipped"; }

    local border_color=2
    [[ $failed -gt 0 ]] && border_color=1

    gum style \
        --border rounded \
        --border-foreground "$border_color" \
        --align center \
        --width 70 \
        --padding "0 2" \
        --bold \
        "Setup complete!" "" "$counts"
    gum style --faint --foreground "" "log file: $LOG_FILE"
}

# ─────────────────────────────────────────────────────────────────────────────
# Export for child scripts
# ─────────────────────────────────────────────────────────────────────────────

export -f tui_set_substep
