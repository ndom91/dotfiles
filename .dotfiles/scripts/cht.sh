#!/usr/bin/env bash
selected=$(cat ~/.dotfiles/scripts/.tmux-cht-languages ~/.dotfiles/scripts/.tmux-cht-command | fzf)
read -r -p "Enter Query: " query

if grep -qs "$selected" ~/.tmux-cht-languages; then
  query=$(echo "$query" | tr ' ' '+')
  echo "curl cht.sh/$selected/$query & while [ : ]; do sleep 1; done"
  tmux neww -n "cht.sh - $query" -c bash "curl cht.sh/$selected/$query & while true ; do sleep 1; done"
else
  echo "curl cht.sh/$selected~$query & while [ : ]; do sleep 1; done"
  tmux neww -n "cht.sh - $query" -d "curl cht.sh/$selected~$query & while [ : ]; do sleep 1; done"
fi
