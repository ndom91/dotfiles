#!/usr/bin/env bash
#           _                 ___  _
#  _ __   __| | ___  _ __ ___ / _ \/ |
# | '_ \ / _` |/ _ \| '_ ` _ \ (_) | |
# | | | | (_| | (_) | | | | | \__, | |
# |_| |_|\__,_|\___/|_| |_| |_| /_/|_|
#
# author: Nico Domino
# github: ndom91
# twitter: @ndom91
#

# shellcheck source=../utils/helpers.sh
. ../utils/helpers.sh

if [ -z "${PLATFORM-}" ]; then
  PLATFORM="$(detect_platform)"
fi

if [ -z "${DISTRO-}" ]; then
  DISTRO="$(get_distribution)"
fi

if [ -z "${ARCH-}" ]; then
  ARCH="$(detect_arch)"
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    -v | --version)
      VERSION="$2"
      shift 2
      ;;
    -p | --platform)
      PLATFORM="$2"
      shift 2
      ;;
    -a | --arch)
      ARCH="$2"
      shift 2
      ;;
    -V | --vim)
      VIM="$2"
      shift 2
      ;;
    --verbose)
      VERBOSE=1
      shift 1
      ;;
    -f | -y | --force | --yes)
      FORCE=1
      shift 1
      ;;
    -v=* | --version=*)
      VERSION="${1#*=}"
      shift 1
      ;;
    -p=* | --platform=*)
      PLATFORM="${1#*=}"
      shift 1
      ;;
    -P=* | --prefix=*)
      PREFIX="${1#*=}"
      shift 1
      ;;
    -a=* | --arch=*)
      ARCH="${1#*=}"
      shift 1
      ;;
    --vim=*)
      VIM="${1#*=}"
      shift 1
      ;;
    -V=* | --verbose=*)
      VERBOSE="${1#*=}"
      shift 1
      ;;
    -f=* | -y=* | --force=* | --yes=*)
      FORCE="${1#*=}"
      shift 1
      ;;
    -*)
      error "Unknown option: $1"
      exit 1
      ;;
    *)
      VERSION="$1"
      shift 1
      ;;
  esac
done

if [ -z "${PKGMGR-}" ]; then
  case "$DISTRO" in
    ubuntu | debian | raspbian)
      PKGMGR='apt -y'
      ;;
    arch)
      PKGMGR='pacman -Sy'
      ;;
    centos)
      PKGMGR='yum'
      ;;
  esac
fi

function wgetdpkg() {
  if [[ ! -e ~/Downloads ]]; then
    mkdir ~/Downloads
  fi
  wget "$2" -O ~/Downloads/"$1"
  dpkg -i ~/Downloads/"$1"
}

function gitsetup() {
  git config --global user.email "yo@ndo.dev"
  git config --global user.name "$(whoami)@$(hostname)"
}

# INIT IF STATEMENT
if [ -z "$1" ]; then
  echo ""
  echo "            _                 __   _"
  echo "  _ __   __| | ___  _ __ ___ / _ \\/ |"
  echo " | '_ \\ / _\` |/ _ \| '_  \` _\ (_) | |"
  echo " | | | | (_| | (_) | | | | | \__, | |"
  echo " |_| |_|\__,_|\___/|_| |_| |_| /_/|_|"
  echo "                          INIT SCRIPT"
  echo ""
  echo "  Please make a selection:"
  echo "  Usage: ./deploy.sh {server|desktop|vim}"
  echo ""

# DESKTOP
elif [ "$1" == "desktop" ]; then
  apt update

  echo "[*] Installing Desktop Apps"
  case "$DISTRO" in
    ubuntu | debian | raspbian)
      pkgMgr install vim most ranger curl sudo tilix tmux nethogs speedtest-cli htop iftop net-tools software-properties-common zip unzip viewnior mupdf sct rofi nemo remmina flameshot nmap fd-find build-essential libssl-dev filezilla vlc
      ;;
    arch)
      yay -Sy vim most vifm curl alacritty tmux speedtest-cli htop iftop viewnior mupdf remmina nmap fd ripgrep gitui bottom vscode-bin sct flameshot fielzilla vlc peek
      ;;
  esac

  # VSCODE
  pkgMgr install snapd
  # snap install code --classic

  # PEEK - GIF RECORDER
  case "$DISTRO" in
    ubuntu | debian | raspbian)
      add-apt-repository ppa:peek-developers/stable
      apt update
      apt install peek
      ;;
  esac

  if ! [ -x "$(command -v npm)" ]; then
    if [ "$PLATFORM" == 'linux' ]; then
      curl -s https://install-node.now.sh | sudo bash -s -- --yes
    elif [ "$PLATFORM" == 'darwin' ]; then
      sudo -u "$SUDO_USER" brew install node 2>/dev/null
    fi
    mkdir ~/npm-global
    npm config set prefix "$HOME/npm-global"
    echo " export PATH=~/npm-global/bin:$PATH" >>"$HOME/.profile"
    # shellcheck source=/home/ndo/.bashrc
    source "$HOME/.bashrc"
    # shellcheck source=/home/ndo/.profile
    source "$HOME/.profile"
  fi

  # GLOBAL NODE APPS
  npm i -g tldr fkill-cli

  # PAPIRUS ICON THEME
  wget -qO- https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install.sh | sh

  # ADAPTA NOKTO GTK THEME
  case "$DISTRO" in
    ubuntu | debian | raspbian)
      apt-add-repository ppa:tista/adapta -y
      apt update && apt install -y adapta-gtk-theme
      ;;
  esac

  # VIM
  vim
  gitsetup

  echo "To swap caps/escape:  "
  echo "[*] setxkbmap -option caps:escape"
  echo "[*] xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'"
  echo ""
  echo "Set Window Manager + Appearance Settings"

# SERVER ARGUMENT
elif [ "$1" == "server" ]; then
  echo "[*] Installing Server Apps"
  apt install vim tmux most speedtest-cli htop screenfetch net-tools software-properties-common zip unzip git wget curl
  mkdir -p ~/Downloads
  # VIM
  vim
  gitsetup

# VIM ARGUMENT
elif [ "$1" == "vim" ]; then
  echo "[*] Installing vim plugins"
  vim
  gitsetup
fi
