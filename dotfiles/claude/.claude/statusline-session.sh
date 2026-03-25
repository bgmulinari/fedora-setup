#!/bin/bash
# Read JSON input once
input=$(cat)

# Extract all fields in a single jq call
eval "$(echo "$input" | jq -r '
    (.data // .) as $d |
    @sh "MODEL=\($d.model.display_name)",
    @sh "CURRENT_DIR=\($d.workspace.current_dir)",
    @sh "CTX_SIZE=\($d.context_window.context_window_size // 200000)",
    @sh "INPUT_TOKENS=\($d.context_window.current_usage.input_tokens // 0)",
    @sh "CACHE_CREATE=\($d.context_window.current_usage.cache_creation_input_tokens // 0)",
    @sh "CACHE_READ=\($d.context_window.current_usage.cache_read_input_tokens // 0)",
    @sh "CTX_PCT=\(($d.context_window.used_percentage // 0) | round)"
')"

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

# True-color ANSI helpers
fg() { printf '\033[38;2;%d;%d;%dm' "$1" "$2" "$3"; }
bg() { printf '\033[48;2;%d;%d;%dm' "$1" "$2" "$3"; }
reset=$'\033[0m'

# Catppuccin Mocha palette (RGB)
surface0=(49 50 68)
text=(205 214 244)
blue=(137 180 250)
base=(30 30 46)
mantle=(24 24 37)
peach=(250 179 135)
green=(166 227 161)
yellow=(249 226 175)
red=(243 139 168)

CURRENT=$(( INPUT_TOKENS + CACHE_CREATE + CACHE_READ ))

# Show git branch if in a git repo
GIT_BRANCH=""
if git -C "$CURRENT_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "$CURRENT_DIR" branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        GIT_BRANCH="$BRANCH"
    fi
fi

# Context color based on usage percentage
if [ "$CTX_PCT" -lt 50 ] 2>/dev/null; then
    ctx=("${green[@]}")
elif [ "$CTX_PCT" -lt 80 ] 2>/dev/null; then
    ctx=("${yellow[@]}")
else
    ctx=("${red[@]}")
fi

# Build token display and progress bar
USED_FMT=$(format_tokens $CURRENT)
TOTAL_FMT=$(format_tokens $CTX_SIZE)
FILLED=$((CTX_PCT * 10 / 100))
EMPTY=$((10 - FILLED))
BAR_USED=""
BAR_EMPTY=""
for ((i=0; i<FILLED; i++)); do BAR_USED+="━"; done
for ((i=0; i<EMPTY; i++)); do BAR_EMPTY+="─"; done

# Build powerline statusline
out=""

# Start cap
out+="$(fg "${peach[@]}")\ue0b6"

# Segment 1: Model (bg:peach fg:base)
out+="$(bg "${peach[@]}")$(fg "${base[@]}")\U000f167a $MODEL "

# Transition to directory
out+="$(bg "${text[@]}")$(fg "${peach[@]}")\ue0b0"

# Segment 2: Directory (bg:text fg:surface0)
out+="$(bg "${text[@]}")$(fg "${surface0[@]}") \uea83 ${CURRENT_DIR##*/} "

if [ -n "$GIT_BRANCH" ]; then
    # Transition to git
    out+="$(bg "${blue[@]}")$(fg "${text[@]}")\ue0b0"
    # Segment 3: Git branch (bg:blue fg:base)
    out+="$(bg "${blue[@]}")$(fg "${base[@]}") \uf126 $GIT_BRANCH "
    # Transition to context
    out+="$(bg "${ctx[@]}")$(fg "${blue[@]}")\ue0b0"
else
    # Transition directly to context
    out+="$(bg "${ctx[@]}")$(fg "${text[@]}")\ue0b0"
fi

# Segment 4: Context usage (bg:ctx fg:mantle, dim bar in surface0)
out+="$(bg "${ctx[@]}")$(fg "${mantle[@]}") ${USED_FMT}/${TOTAL_FMT} ${BAR_USED}"
out+="$(fg "${surface0[@]}")${BAR_EMPTY}"
out+="$(fg "${mantle[@]}") ${CTX_PCT}%"

# End cap
out+="${reset}$(fg "${ctx[@]}")\ue0b4${reset}"

echo -e "$out"
