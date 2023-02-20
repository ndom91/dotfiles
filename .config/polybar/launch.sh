#!/bin/bash

# Polybar start script
# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

desktop="i3"
hostname=$(hostname)

case $desktop in
i3)
  if type "xrandr" >/dev/null; then
    if [[ "$hostname" == "ndo1" ]]; then
      for m in $(xrandr --listactivemonitors | grep -oP '(DP\d+$|DVI\-I\-\d+(\-\d+?)$|eDP\d+$)'); do
        if [ "$m" == 'eDP1' ]; then
          echo "eDP1 $m"
          MONITOR=$m polybar --reload top -c ~/.config/polybar/config.ini &
          MONITOR=$m polybar --reload bottom -c ~/.config/polybar/config.ini &
        elif [ "$m" == 'DP1' ]; then
          echo "DP1 $m"
          MONITOR=$m polybar --reload topleft -c ~/.config/polybar/config.ini &
        elif [ "$m" == 'DVI-I-2-2' ]; then
          echo "DVI-I-2-2 $m"
          MONITOR=$m polybar --reload topright -c ~/.config/polybar/config.ini &
        elif [ "$m" == 'DVI-I-1-1' ]; then
          echo "DVI-I-1-1 $m"
          MONITOR=$m polybar --reload top -c ~/.config/polybar/config.ini &
          MONITOR="DVI-I-1-1" polybar --reload bottom -c ~/.config/polybar/config.ini &
        fi
      done
    elif [[ "$hostname" == "ndo4" ]]; then
      echo "ndo4"
      for m in $(xrandr --listactivemonitors | grep -oP '(HDMI\-\d+$|DisplayPort-\d+$|VGA\-\d+$)'); do
        if [ "$m" == 'DisplayPort-1' ]; then
          echo "DisplayPort-1 $m"
          MONITOR=$m polybar --reload top -c ~/.config/polybar/config.ini &
          MONITOR=$m polybar --reload bottom -c ~/.config/polybar/config.ini &
        elif [ "$m" == 'DisplayPort-0' ]; then
          echo "DisplayPort-0 $m"
          MONITOR=$m polybar --reload topleft -c ~/.config/polybar/config.ini &
        elif [ "$m" == 'DisplayPort-2' ]; then
          echo "DisplayPort-2 $m"
          MONITOR=$m polybar --reload topright -c ~/.config/polybar/config.ini &
        fi
      done
    fi
  fi
  ;;
openbox)
  if type "xrandr" >/dev/null; then
    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
      MONITOR=$m polybar --reload mainbar-openbox -c ~/.config/polybar/config.ini &
    done
  else
    polybar --reload mainbar-openbox -c ~/.config/polybar/config.ini &
  fi

  ;;
bspwm)
  if type "xrandr" >/dev/null; then
    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
      MONITOR=$m polybar --reload mainbar-bspwm -c ~/.config/polybar/config.ini &
    done
  else
    polybar --reload mainbar-bspwm -c ~/.config/polybar/config.ini &
  fi
  ;;
esac
