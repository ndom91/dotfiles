#!/usr/bin/env bash

packages=(
  # main hyprland + patches
  hyprland-hidpi-xprop-git
  xdg-desktop-portal-hyprland-git
  # i3 like tiling functionality
  hy3-git
  # Menu bar
  waybar
  rofi-lbonn-wayland-git
  # Notifications
  swaync
  # Fonts
  noto-fonts-emoji
  # Misc tools
  cliphist nwg-look-bin
  swaybg swaylock-effects-git wlogout
  swayidle swayosd-git wlsunset
  imv flemozi-bin
  python-neovim-git python-libtmux

  # xwayland
  xsettingsd xorg-xsetroot

  # Deps
  polkit-gnome python-requests starship
  brightnessctl inotify-tools
  # Screenshots
  swappy satty-bin grim slurp
  # Video
  wf-recorder
  # Audio
  pamixer
  # Bluetooth
  bluez bluez-utils blueberry-wayland
  # Themes
  dracula-gtk-theme dracula-icons-git
  catppuccin-gtk-theme-mocha
  bibata-cursor-theme-bin
  rose-pine-cursor
)

yay -S "${packages[@]}"

# hidpi
# hyprland-hidpi-xprop-git
# Modify .Xresources 'Xft.dpi = 192' && xrdb -merge ~/.Xresources
