#!/bin/bash
# Read JSON input once
input=$(cat)

# Helper functions for common extractions
get_model_name() { echo "$input" | jq -r '(.data // .).model.display_name'; }
get_current_dir() { echo "$input" | jq -r '(.data // .).workspace.current_dir'; }
get_context_used_pct() { echo "$input" | jq -r '((.data // .).context_window.used_percentage // 0) | round'; }

MODEL=$(get_model_name)
CURRENT_DIR=$(get_current_dir)
CONTEXT_PCT=$(get_context_used_pct)

# Show git branch if in a git repo
GIT_BRANCH=""
if git -C "$CURRENT_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "$CURRENT_DIR" branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        GIT_BRANCH=" | \uf126 $BRANCH"
    fi
fi

MODELINFO="[\033[38;5;208m$MODEL\033[0m]"

# Build color-coded context progress bar
CONTEXTINFO=""
PCT_INT=${CONTEXT_PCT%%.*}
if [ "$PCT_INT" -lt 50 ] 2>/dev/null; then
    BAR_COLOR="\033[32m"
elif [ "$PCT_INT" -lt 80 ] 2>/dev/null; then
    BAR_COLOR="\033[33m"
else
    BAR_COLOR="\033[31m"
fi
FILLED=$((PCT_INT * 10 / 100))
EMPTY=$((10 - FILLED))
USED=""
AVAIL=""
for ((i=0; i<FILLED; i++)); do USED+="━"; done
for ((i=0; i<EMPTY; i++)); do AVAIL+="─"; done
CONTEXTINFO=" | ${BAR_COLOR}${USED}\033[0m${AVAIL} ${PCT_INT}%"

echo -e "$MODELINFO \uea83 ${CURRENT_DIR##*/}$GIT_BRANCH$CONTEXTINFO"
