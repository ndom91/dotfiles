#!/bin/sh

cd ~ || exit

# export _JAVA_AWT_WM_NONREPARENTING=1
export XCURSOR_SIZE=24
export XDG_SESSION_TYPE=wayland
export MOZ_ENABLE_WAYLAND=1
# export QT_QPA_PLATFORMTHEME=qt5ct
# export QT_STYLE_OVERRIDE=kvantum

m=$(cat /sys/class/drm/card0-DP-1/status)
n=$(cat /sys/class/drm/card0-DP-2/status)

if [ "$m" = 'disconnected' ] && [ "$n" = 'disconnected' ]; then
  export LAPTOP=0
  exec Hyprland
else
  export LAPTOP=1
  # export WLR_DRM_DEVICES=/dev/dri/card1
  exec Hyprland
fi
