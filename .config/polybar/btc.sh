#!/bin/bash

LC_NUMERIC="en_US.UTF-8"

# Get current Price from rate.sx
RATE=$(curl -s eur.rate.sx/1btc)

# Round it off
RATE=$(printf "%.2f\n" "$RATE")

# Append BTC Icon
echo "€$RATE"
