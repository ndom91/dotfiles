function vim() {

  echo "[*] Installing vim + vim plugins"
  echo""

  if ! hash git 2>/dev/null; then
    PKGMGR install git
  fi
  if ! hash wget 2>/dev/null; then
    PKGMGR install wget
  fi
  if ! hash vim 2>/dev/null; then
    case "$DISTRO" in
    ubuntu | debian | raspbian)
      add-apt-repository -y ppa:jonathonf/vim
      ;;
    esac
    PKGMGR install vim
  fi

  echo ""

  BASE_DIR="$HOME/.vim"
  COLORS_DIR="$BASE_DIR/colors"

  echo "[*] Making appropriate directories"
  echo ""

  mkdir -p "$COLORS_DIR"

  echo "[*] Getting .vimrc from ndom91/dotfiles + dracula.vim colors"
  echo ""

  if [ ! -f "$HOME"/.vimrc ]; then
    wget https://raw.githubusercontent.com/ndom91/dotfiles/main/.vimrc?token=ABYSRMHNTA7JI4BMYSSQLAS7L5YHI -O "$HOME"/.vimrc
  fi
  wget https://raw.githubusercontent.com/dracula/vim/b7e11c087fe2a9e3023cdccf17985704e27b125d/colors/dracula.vim -O "$COLORS_DIR"/dracula.vim

  echo "[*] Installing vim plugins..."
  echo ""

  if [ "$PLATFORM" == 'linux' ]; then
    if ! dpkg -s python3-dev &>/dev/null; then
      sudo apt install -y python3-dev
    fi
  elif [ "$DISTRO" == 'centos' ]; then
    if ! yum list installed | grep python3-devel; then
      sudo yum install -y python3-devel
    fi
  fi

  if [ "$PLATFORM" == 'linux' ]; then
    pkgMgr install cmake
    pkgMgr install build-essential
  elif [ "$DISTRO" == 'centos' ]; then
    pkgMgr install cmake
    pkgMgr groupinstall 'Development Tools'
  fi

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

  # shellcheck source=/home/ndo/.bashrc
  source "$HOME/.bashrc"

  npm list -g --depth 0 | grep typescript >>/dev/null
  retVal=$?
  if [ $retVal -ne 0 ]; then
    npm i -g typescript
  fi

  if [ "$PLATFORM" == 'linux' ]; then
    if ! dpkg -l | grep -qw python3; then
      # if [ $? -eq 0 ]; then
      sudo apt install -y python3
    fi
  elif [ "$DISTRO" == 'centos' ]; then
    yum list installed | grep python3
    if [ $? -eq 1 ]; then
      sudo yum install -y python3
    fi
  fi

  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  vim -c :PlugInstall

  chown -R "$SUDO_USER": /home/"$SUDO_USER"/

  echo "[*] vim setup done <3"
}

[ "$0" = "${BASH_SOURCE[0]}" ] && display_version 0.0.1 || true

