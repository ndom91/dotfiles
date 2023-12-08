#!/bin/bash
# Move focus script to workaround hy3 not supporting movefocus
# across multiple monitors
# see: https://github.com/outfoxxed/hy3/issues/2

NowWindow="$(hyprctl activewindow -j | jaq ".address")"
if [ "$1" == "right" ] ; then
  hyprctl dispatch hy3:movefocus r && sleep 0.05
  ThenWindow="$(hyprctl activewindow -j | jaq ".address")"
  if [ "$NowWindow" == "$ThenWindow" ]; then
    # hyprctl dispatch focusmonitor +1
    hyprctl dispatch movefocus r 
  fi
elif [ "$1" == "left" ] ; then
  hyprctl dispatch hy3:movefocus l && sleep 0.05
  ThenWindow="$(hyprctl activewindow -j | jaq ".address")"
  if [ "$NowWindow" == "$ThenWindow" ]; then
    # hyprctl dispatch focusmonitor -1
    hyprctl dispatch movefocus l 
  fi
fi
