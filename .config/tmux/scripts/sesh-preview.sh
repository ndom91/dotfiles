#!/usr/bin/env bash
# Custom sesh preview that shows all panes in the active window of a tmux session.
# Falls back to `sesh preview` for non-tmux entries (zoxide paths, config sessions).

TMUX_BIN="/opt/homebrew/bin/tmux"

# Strip ANSI escape codes and leading icon+space to extract session name
session_name=$(echo "$1" | sed 's/\x1b\[[0-9;]*m//g' | sed 's/^[^ ]* //')

# Check if this is an active tmux session
if ! $TMUX_BIN has-session -t "=$session_name" 2>/dev/null; then
  # Not a running tmux session — fall back to sesh preview
  exec sesh preview "$1"
fi

# Get pane count in the active window
pane_count=$($TMUX_BIN list-panes -t "=$session_name" -F '#{pane_index}' | wc -l | tr -d ' ')

if [ "$pane_count" -le 1 ]; then
  # Single pane — capture with explicit pane target
  $TMUX_BIN capture-pane -t "=$session_name:.1" -e -p
  exit 0
fi

# Get pane info: index, width, height, top position, left position
pane_info=$($TMUX_BIN list-panes -t "=$session_name" \
  -F '#{pane_index}:#{pane_width}:#{pane_height}:#{pane_top}:#{pane_left}')

# Determine layout direction by checking if panes share left position (vertical stack)
# or share top position (horizontal split)
first_left=$(echo "$pane_info" | head -1 | cut -d: -f5)
all_same_left=true
while IFS=: read -r _ _ _ _ left; do
  if [ "$left" != "$first_left" ]; then
    all_same_left=false
    break
  fi
done <<< "$pane_info"

# Preview dimensions from fzf (fallback to reasonable defaults)
preview_cols=${FZF_PREVIEW_COLUMNS:-80}
preview_lines=${FZF_PREVIEW_LINES:-40}

# Separator line
separator=$(printf '%.0s─' $(seq 1 "$preview_cols"))

if $all_same_left; then
  # Vertical stack layout — show panes stacked with separators
  # Calculate proportional heights
  total_pane_height=0
  while IFS=: read -r _ _ height _ _; do
    total_pane_height=$((total_pane_height + height))
  done <<< "$pane_info"

  separator_lines=$(( pane_count - 1 ))
  available_lines=$(( preview_lines - separator_lines ))

  first=true
  while IFS=: read -r idx _ height _ _; do
    if ! $first; then
      echo "$separator"
    fi
    first=false

    # Proportional line count for this pane
    if [ "$total_pane_height" -gt 0 ]; then
      pane_lines=$(( (height * available_lines) / total_pane_height ))
      [ "$pane_lines" -lt 3 ] && pane_lines=3
    else
      pane_lines=$available_lines
    fi

    $TMUX_BIN capture-pane -t "=$session_name:.${idx}" -e -p | tail -n "$pane_lines"
  done <<< "$pane_info"
else
  # Side-by-side layout — show panes stacked with labels since terminal
  # preview can't do true side-by-side easily
  first=true
  while IFS=: read -r idx width height _ _; do
    if ! $first; then
      echo "$separator"
    fi
    first=false

    pane_lines=$(( preview_lines / pane_count - 1 ))
    [ "$pane_lines" -lt 3 ] && pane_lines=3

    $TMUX_BIN capture-pane -t "=$session_name:.${idx}" -e -p | tail -n "$pane_lines"
  done <<< "$pane_info"
fi
