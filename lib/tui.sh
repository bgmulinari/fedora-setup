#!/bin/bash
#
# TUI Library for Fedora Setup Script
# Provides split-view terminal interface with progress tracking
#

# ─────────────────────────────────────────────────────────────────────────────
# TUI State Variables
# ─────────────────────────────────────────────────────────────────────────────

TUI_ENABLED=0
TUI_TERM_LINES=0
TUI_TERM_COLS=0
TUI_HEADER_HEIGHT=12
TUI_CURRENT_MODULE=""
TUI_CURRENT_MODULE_IDX=0
TUI_SUBSTEP_TEXT=""

# Module status: pending, running, done, skipped, error
declare -A TUI_MODULE_STATUS=()

# ─────────────────────────────────────────────────────────────────────────────
# ANSI/tput Helpers
# ─────────────────────────────────────────────────────────────────────────────

_tui_goto() { tput cup "$1" "$2" 2>/dev/null || true; }
_tui_clear_eol() { tput el 2>/dev/null || true; }
_tui_hide_cursor() { tput civis 2>/dev/null || true; }
_tui_show_cursor() { tput cnorm 2>/dev/null || true; }
_tui_save_cursor() { tput sc 2>/dev/null || true; }
_tui_restore_cursor() { tput rc 2>/dev/null || true; }
_tui_set_scroll_region() { tput csr "$1" "$2" 2>/dev/null || true; }
_tui_reset_scroll_region() { tput csr 0 $((TUI_TERM_LINES - 1)) 2>/dev/null || true; }

_tui_repeat() {
    local char="$1" count="$2"
    local i
    for ((i=0; i<count; i++)); do
        printf '%s' "$char"
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# Core TUI Functions
# ─────────────────────────────────────────────────────────────────────────────

tui_init() {
    # Check if stdout is a terminal
    if [[ ! -t 1 ]]; then
        TUI_ENABLED=0
        return 0
    fi

    # Check if we can use tput at all
    if ! command -v tput &>/dev/null; then
        TUI_ENABLED=0
        return 0
    fi

    # Check TERM is set (might not be under some sudo configurations)
    if [[ -z "${TERM:-}" || "$TERM" == "dumb" ]]; then
        TUI_ENABLED=0
        return 0
    fi

    TUI_TERM_LINES=$(tput lines 2>/dev/null) || TUI_TERM_LINES=24
    TUI_TERM_COLS=$(tput cols 2>/dev/null) || TUI_TERM_COLS=80

    # Graceful degradation for small terminals
    if [[ $TUI_TERM_COLS -lt 60 || $TUI_TERM_LINES -lt 20 ]]; then
        TUI_ENABLED=0
        return 0
    fi

    TUI_ENABLED=1

    # Initialize module status (with error handling for set -e)
    local module
    for module in $ALL_MODULES; do
        TUI_MODULE_STATUS["$module"]="pending"
    done

    # Set up resize handler
    trap '_tui_handle_resize' WINCH

    # Clear screen and hide cursor
    clear
    _tui_hide_cursor

    # Draw initial header (wrapped in subshell to catch any errors)
    if ! _tui_draw_header; then
        # If header drawing fails, disable TUI and continue
        TUI_ENABLED=0
        _tui_show_cursor
        return 0
    fi

    # Set scroll region to log area only
    _tui_set_scroll_region $TUI_HEADER_HEIGHT $((TUI_TERM_LINES - 1))

    # Move cursor to log area
    _tui_goto $TUI_HEADER_HEIGHT 0

    return 0
}

tui_cleanup() {
    if [[ $TUI_ENABLED -eq 1 ]]; then
        _tui_reset_scroll_region
        _tui_show_cursor
        _tui_goto $((TUI_TERM_LINES - 1)) 0
        echo ""
    fi
}

_tui_handle_resize() {
    if [[ $TUI_ENABLED -eq 0 ]]; then
        return 0
    fi

    TUI_TERM_LINES=$(tput lines 2>/dev/null || echo 24)
    TUI_TERM_COLS=$(tput cols 2>/dev/null || echo 80)

    _tui_save_cursor
    _tui_draw_header
    _tui_set_scroll_region $TUI_HEADER_HEIGHT $((TUI_TERM_LINES - 1))
    _tui_restore_cursor
}

# ─────────────────────────────────────────────────────────────────────────────
# Header Drawing
# ─────────────────────────────────────────────────────────────────────────────

_tui_draw_header() {
    local width=$TUI_TERM_COLS
    local completed=0
    local total=0
    local running=0

    # Count modules
    local module
    for module in $ALL_MODULES; do
        ((total++)) || true
        local status="${TUI_MODULE_STATUS[$module]:-pending}"
        case "$status" in
            done|skipped) ((completed++)) || true ;;
            running) ((running++)) || true ;;
        esac
    done

    _tui_save_cursor

    # Line 0: Top border
    _tui_goto 0 0
    printf "${BLUE}┌%s┐${NC}" "$(_tui_repeat '─' $((width-2)))"
    _tui_clear_eol

    # Line 1: Title
    _tui_goto 1 0
    local title="Fedora Auto-Setup Script"
    local padding=$(( (width - ${#title} - 2) / 2 ))
    [[ $padding -lt 0 ]] && padding=0
    printf "${BLUE}│${NC}%*s${GREEN}%s${NC}%*s${BLUE}│${NC}" \
        $padding "" "$title" $((width - padding - ${#title} - 2)) ""
    _tui_clear_eol

    # Line 2: Separator
    _tui_goto 2 0
    printf "${BLUE}├%s┤${NC}" "$(_tui_repeat '─' $((width-2)))"
    _tui_clear_eol

    # Line 3: Progress bar
    _tui_goto 3 0
    _tui_draw_progress_bar $((completed + running)) $total $((width - 4))

    # Line 4: Empty
    _tui_goto 4 0
    printf "${BLUE}│${NC}%*s${BLUE}│${NC}" $((width-2)) ""
    _tui_clear_eol

    # Line 5: Current module
    _tui_goto 5 0
    local module_text="  Current Module: ${TUI_CURRENT_MODULE:-Starting...}"
    printf "${BLUE}│${NC}${GREEN}%-*s${NC}${BLUE}│${NC}" $((width-2)) "$module_text"
    _tui_clear_eol

    # Line 6: Sub-step status
    _tui_goto 6 0
    local status_text="  Status: ${TUI_SUBSTEP_TEXT:-Initializing...}"
    # Truncate if too long
    local max_len=$((width - 4))
    if [[ ${#status_text} -gt $max_len ]]; then
        status_text="${status_text:0:$((max_len - 3))}..."
    fi
    printf "${BLUE}│${NC}%-*s${BLUE}│${NC}" $((width-2)) "$status_text"
    _tui_clear_eol

    # Line 7: Empty
    _tui_goto 7 0
    printf "${BLUE}│${NC}%*s${BLUE}│${NC}" $((width-2)) ""
    _tui_clear_eol

    # Lines 8-9: Module grid
    _tui_draw_module_grid

    # Line 10: Empty
    _tui_goto 10 0
    printf "${BLUE}│${NC}%*s${BLUE}│${NC}" $((width-2)) ""
    _tui_clear_eol

    # Line 11: Bottom border (end of header)
    _tui_goto 11 0
    printf "${BLUE}└%s┘${NC}" "$(_tui_repeat '─' $((width-2)))"
    _tui_clear_eol

    _tui_restore_cursor
}

_tui_draw_progress_bar() {
    local current=$1 total=$2 width=$3
    local bar_width=$((width - 27))
    [[ $bar_width -lt 10 ]] && bar_width=10
    local filled=0

    if [[ $total -gt 0 ]]; then
        filled=$((current * bar_width / total))
    fi

    local empty=$((bar_width - filled))
    local pct=0
    if [[ $total -gt 0 ]]; then
        pct=$((current * 100 / total))
    fi

    printf "${BLUE}│${NC}  Progress: ["
    printf "${GREEN}%s${NC}" "$(_tui_repeat '█' $filled)"
    printf "%s" "$(_tui_repeat '░' $empty)"
    printf "] %2d/%d (%3d%%)  ${BLUE}│${NC}" "$current" "$total" "$pct"
    _tui_clear_eol
}

_tui_draw_module_grid() {
    local width=$TUI_TERM_COLS
    local -a modules=($ALL_MODULES)
    local col_width=15

    # Row 1: First 5 modules (line 8)
    _tui_goto 8 0
    printf "${BLUE}│${NC}  "
    local i
    for ((i=0; i<5 && i<${#modules[@]}; i++)); do
        local m="${modules[$i]}"
        local status="${TUI_MODULE_STATUS[$m]:-pending}"
        _tui_print_module_status "$m" "$status"
    done
    local remaining=$((width - 2 - 5*col_width - 2))
    [[ $remaining -lt 0 ]] && remaining=0
    printf "%*s${BLUE}│${NC}" $remaining ""
    _tui_clear_eol

    # Row 2: Next 6 modules (line 9)
    _tui_goto 9 0
    printf "${BLUE}│${NC}  "
    for ((i=5; i<11 && i<${#modules[@]}; i++)); do
        local m="${modules[$i]}"
        local status="${TUI_MODULE_STATUS[$m]:-pending}"
        _tui_print_module_status "$m" "$status"
    done
    remaining=$((width - 2 - 6*col_width - 2))
    [[ $remaining -lt 0 ]] && remaining=0
    printf "%*s${BLUE}│${NC}" $remaining ""
    _tui_clear_eol
}

_tui_print_module_status() {
    local name="$1"
    local status="$2"
    local icon

    case "$status" in
        done)    icon="${GREEN}[✓]${NC}" ;;
        running) icon="${YELLOW}[▸]${NC}" ;;
        skipped) icon="${BLUE}[−]${NC}" ;;
        error)   icon="${RED}[✗]${NC}" ;;
        *)       icon="[ ]" ;;
    esac

    printf "%b %-10s " "$icon" "$name"
}

# ─────────────────────────────────────────────────────────────────────────────
# Module Progress Functions
# ─────────────────────────────────────────────────────────────────────────────

tui_start_module() {
    local module="$1"
    TUI_CURRENT_MODULE="$module"
    ((TUI_CURRENT_MODULE_IDX++)) || true
    TUI_MODULE_STATUS[$module]="running"
    TUI_SUBSTEP_TEXT="Starting..."

    if [[ $TUI_ENABLED -eq 1 ]]; then
        _tui_draw_header
    fi
}

tui_end_module() {
    local module="$1"
    local status="${2:-done}"
    TUI_MODULE_STATUS[$module]="$status"
    TUI_SUBSTEP_TEXT=""

    if [[ $TUI_ENABLED -eq 1 ]]; then
        _tui_draw_header
    fi
}

tui_skip_module() {
    local module="$1"
    TUI_MODULE_STATUS[$module]="skipped"

    if [[ $TUI_ENABLED -eq 1 ]]; then
        _tui_draw_header
    fi
}

tui_set_substep() {
    TUI_SUBSTEP_TEXT="$1"

    if [[ $TUI_ENABLED -eq 1 ]]; then
        local width=$TUI_TERM_COLS
        local status_text="  Status: ${TUI_SUBSTEP_TEXT:-Processing...}"
        # Truncate if too long
        local max_len=$((width - 4))
        if [[ ${#status_text} -gt $max_len ]]; then
            status_text="${status_text:0:$((max_len - 3))}..."
        fi

        _tui_save_cursor
        _tui_goto 6 0
        printf "${BLUE}│${NC}%-*s${BLUE}│${NC}" $((width-2)) "$status_text"
        _tui_clear_eol
        _tui_restore_cursor
    fi
}

# Export TUI state and functions for child scripts
export TUI_ENABLED
export -f tui_set_substep
