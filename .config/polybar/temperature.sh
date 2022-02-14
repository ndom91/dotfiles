#!/bin/bash
# this script read the core(s) temperature using lm sensors then calculate the average
# and send it to the ganglia using gmetric
# Based on the original from: http://computational.engineering.or.id/LM_Sensors#Integrasi_Dengan_Ganglia
# assumes that the lines reported by lm sensors are formated like this
# Core 0:      +48.0°C  (high = +90.0°C, crit = +100.0°C)

SENSORS=/usr/bin/sensors

count=
sum=0.0
# for temp in $($SENSORS | grep "^Tdie\|^Core 0" | grep -e '.*C' | cut -f 2 -d '+' | cut -f 1 -d ' ' | sed 's/°C//'); do
for temp in $($SENSORS | grep "^Tctl\|^Core 0" | grep -e '.*C' | cut -f 2 -d '+' | cut -f 1 -d ' ' | sed 's/°C//'); do
  sum=$(echo "$sum"+"$temp" | bc)
  # echo $temp, $sum
  ((count += 1))
done
temp=$(echo "$sum/$count" | bc)
echo "$temp"
