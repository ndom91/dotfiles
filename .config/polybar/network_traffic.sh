#!/bin/bash

set -euo pipefail

print_bytes() {
  if [ "$1" -eq 0 ] || [ "$1" -lt 1000 ]; then
    bytes="0 kB/s"
  elif [ "$1" -lt 1000000 ]; then
    bytes="$(echo "scale=0;$1/1000" | bc -l) kB/s"
  else
    bytes="$(echo "scale=1;$1/1000000" | bc -l) MB/s"
  fi

  echo "$bytes"
}

print_bits() {
  if [ "$1" -eq 0 ] || [ "$1" -lt 10 ]; then
    bit="0 B"
  elif [ "$1" -lt 100 ]; then
    bit="$(echo "scale=0;$1*8" | bc -l) b/s"
  elif [ "$1" -lt 100000 ]; then
    bit="$(echo "scale=0;$1*8/1000" | bc -l) Kb/s"
  else
    bit="$(echo "scale=1;$1*8/1000000" | bc -l) Mb/s"
  fi

  echo "$bit"
}

INTERVAL=3
INTERFACES=""

if [[ "$(hostname)" == "ndo4" ]]; then
  INTERFACES="wlan0"
elif [[ "$(hostname)" == "ndo1" ]]; then
  INTERFACES="wlan0"
fi

declare -A bytes

for interface in $INTERFACES; do
  bytes[past_rx_$interface]="$(cat /sys/class/net/"$interface"/statistics/rx_bytes)"
  bytes[past_tx_$interface]="$(cat /sys/class/net/"$interface"/statistics/tx_bytes)"
done

while true; do
  down=0
  up=0

  for interface in $INTERFACES; do
    bytes[now_rx_$interface]="$(cat /sys/class/net/"$interface"/statistics/rx_bytes)"
    bytes[now_tx_$interface]="$(cat /sys/class/net/"$interface"/statistics/tx_bytes)"

    bytes_down=$((((${bytes[now_rx_$interface]} - ${bytes[past_rx_$interface]})) / INTERVAL))
    bytes_up=$((((${bytes[now_tx_$interface]} - ${bytes[past_tx_$interface]})) / INTERVAL))

    down=$(((("$down" + "$bytes_down"))))
    up=$(((("$up" + "$bytes_up"))))

    bytes[past_rx_$interface]=${bytes[now_rx_$interface]}
    bytes[past_tx_$interface]=${bytes[now_tx_$interface]}
  done

  # echo " $(print_bytes $down) 祝 $(print_bytes $up)"
  echo " $(print_bits $down) 祝 $(print_bits $up)"

  sleep $INTERVAL
done
