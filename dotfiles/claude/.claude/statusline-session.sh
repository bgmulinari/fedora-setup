#!/bin/bash
# Read JSON input once
input=$(cat)

# Helper functions for common extractions
get_model_name() { echo "$input" | jq -r '(.data // .).model.display_name'; }
get_current_dir() { echo "$input" | jq -r '(.data // .).workspace.current_dir'; }
get_context_used_pct() { echo "$input" | jq -r '((.data // .).context_window.used_percentage // 0) | round'; }
get_context_size() { echo "$input" | jq -r '((.data // .).context_window.context_window_size // 200000)'; }
get_input_tokens() { echo "$input" | jq -r '((.data // .).context_window.current_usage.input_tokens // 0)'; }
get_cache_create() { echo "$input" | jq -r '((.data // .).context_window.current_usage.cache_creation_input_tokens // 0)'; }
get_cache_read() { echo "$input" | jq -r '((.data // .).context_window.current_usage.cache_read_input_tokens // 0)'; }

format_tokens() {
    local num=$1
    if [ "$num" -ge 1000000 ]; then
        awk "BEGIN {printf \"%.1fm\", $num / 1000000}"
    elif [ "$num" -ge 1000 ]; then
        awk "BEGIN {printf \"%.0fk\", $num / 1000}"
    else
        printf "%d" "$num"
    fi
}

MODEL=$(get_model_name)
CURRENT_DIR=$(get_current_dir)
CTX_SIZE=$(get_context_size)
INPUT_TOKENS=$(get_input_tokens)
CACHE_CREATE=$(get_cache_create)
CACHE_READ=$(get_cache_read)
CURRENT=$(( INPUT_TOKENS + CACHE_CREATE + CACHE_READ ))
CTX_PCT=$(get_context_used_pct)

# Show git branch if in a git repo
GIT_BRANCH=""
if git -C "$CURRENT_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "$CURRENT_DIR" branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        GIT_BRANCH=" | \uf126 $BRANCH"
    fi
fi

MODELINFO="[\033[38;5;208m$MODEL\033[0m]"

# Build color-coded context display with token count and progress bar
USED_FMT=$(format_tokens $CURRENT)
TOTAL_FMT=$(format_tokens $CTX_SIZE)

if [ "$CTX_PCT" -lt 50 ] 2>/dev/null; then
    BAR_COLOR="\033[32m"
elif [ "$CTX_PCT" -lt 80 ] 2>/dev/null; then
    BAR_COLOR="\033[33m"
else
    BAR_COLOR="\033[31m"
fi
FILLED=$((CTX_PCT * 10 / 100))
EMPTY=$((10 - FILLED))
USED=""
AVAIL=""
for ((i=0; i<FILLED; i++)); do USED+="━"; done
for ((i=0; i<EMPTY; i++)); do AVAIL+="─"; done
CONTEXTINFO=" | ${USED_FMT}/${TOTAL_FMT} ${BAR_COLOR}${USED}\033[0m${AVAIL} ${CTX_PCT}%"

echo -e "$MODELINFO \uea83 ${CURRENT_DIR##*/}$GIT_BRANCH$CONTEXTINFO"
