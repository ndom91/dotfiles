#!/usr/bin/env bash

percent=$(cat /sys/class/power_supply/BAT0/capacity)
remaining=$(acpi | awk '{print $5}')
if [[ $percent -lt 3 ]]; then
  notify-send "BATTERY: $percent!"
  echo "$percent [$remaining]"
elif [[ "$percent" -gt 93 ]]; then
  echo "$percent"
elif [[ "$percent" -gt 5 ]]; then
  echo "$percent [$remaining]"
fi
