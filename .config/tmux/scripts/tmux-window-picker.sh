#!/usr/bin/env bash

set -eu

target="$({
  tmux list-windows -a -F $'#{session_name}:#{window_index}\t#{?window_active,*, } #{session_name}:#{window_index} #{window_name}#{?window_zoomed_flag, [zoom],}#{?window_last_flag, [last],}'
} | fzf-tmux -p 80%,70% \
  --border-label ' windows ' \
  --prompt 'win> ' \
  --header '  tab move  enter switch' \
  --delimiter=$'\t' \
  --with-nth=2.. \
  --bind 'tab:down,btab:up' \
  --preview-window 'right:50%' \
  --preview 'tmux list-panes -t {1} -F "#{?pane_active,> ,  } pane #{pane_index}: #{pane_current_command}  #{pane_current_path}"'
)" || true

[ -n "$target" ] || exit 0

tmux switch-client -t "${target%%$'\t'*}"
