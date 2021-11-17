#!/bin/bash

# totalPac=$(pacman -Qu | wc -l)
# totalYay=$(yay -Qu | wc -l) # Checks AUR and Pacman Updates

check=$(yay -Qu | wc -l)
if [[ "$check" != "0" ]]; then
  echo $check
else
  echo "0"
fi
