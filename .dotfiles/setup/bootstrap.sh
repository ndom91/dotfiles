#!/usr/bin/env bash
#
# DOTFILES INIT SCRIPT
# Updated: 23.04.22
#

# Check which package managers are available
apk=$(command -v apk 2> /dev/null)
apt_get=$(command -v apt-get 2> /dev/null)
brew=$(command -v brew 2> /dev/null)
pkg=$(command -v pkg 2> /dev/null)
pacman=$(command -v pacman 2> /dev/null)
yum=$(command -v yum 2> /dev/null)

distribution=
release=
version=
codename=
package_installer=
tree=
detection=
NAME=
ID=
ID_LIKE=
VERSION=
VERSION_ID=

##### SETUP #####
BOLD="$(tput bold 2>/dev/null || echo '')"
GREY="$(tput setaf 0 2>/dev/null || echo '')"
UNDERLINE="$(tput smul 2>/dev/null || echo '')"
RED="$(tput setaf 1 2>/dev/null || echo '')"
GREEN="$(tput setaf 2 2>/dev/null || echo '')"
YELLOW="$(tput setaf 3 2>/dev/null || echo '')"
BLUE="$(tput setaf 4 2>/dev/null || echo '')"
MAGENTA="$(tput setaf 5 2>/dev/null || echo '')"
CYAN="$(tput setaf 6 2>/dev/null || echo '')"
NO_COLOR="$(tput sgr0 2>/dev/null || echo '')"

info() {
    printf "${BOLD}${BLUE}>${NO_COLOR} $@\n"
}

warn() {
    printf "${YELLOW}! $@${NO_COLOR}\n"
}

error() {
    printf "${RED}x $@${NO_COLOR}\n" >&2
}

complete() {
    printf "${GREEN}✓${NO_COLOR} $@\n"
}

function not_installed() {
  [ ! -x "$(command -v "$@")" ]
}

function ask_for_sudo() {
  # Ask for the administrator password upfront.
  sudo -v &>/dev/null

  # Update existing `sudo` time stamp
  # until this script has finished.
  #
  # https://gist.github.com/cowboy/3118588
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done &>/dev/null &
}

user_picks_distribution() {
  # let the user pick a distribution

  echo >&2
  echo >&2 "I NEED YOUR HELP"
  echo >&2 "It seems I cannot detect your system automatically."

  if [ "${NON_INTERACTIVE}" -eq 1 ]; then
    echo >&2 "Running in non-interactive mode"
    echo >&2 " > Bailing out..."
    exit 1
  fi

  if [ -z "${equo}" ] && [ -z "${emerge}" ] && [ -z "${apt_get}" ] && [ -z "${yum}" ] && [ -z "${dnf}" ] && [ -z "${pacman}" ] && [ -z "${apk}" ] && [ -z "${swupd}" ]; then
    echo >&2 "And it seems I cannot find a known package manager in this system."
    echo >&2 "Please open a github issue to help us support your system too."
    exit 1
  fi

  local opts=
  echo >&2 "I found though that the following installers are available:"
  echo >&2
  [ -n "${apt_get}" ] && echo >&2 " - Debian/Ubuntu based (installer is: apt-get)" && opts="apt-get ${opts}"
  [ -n "${yum}" ] && echo >&2 " - Red Hat/Fedora/CentOS based (installer is: yum)" && opts="yum ${opts}"
  [ -n "${dnf}" ] && echo >&2 " - Red Hat/Fedora/CentOS based (installer is: dnf)" && opts="dnf ${opts}"
  [ -n "${zypper}" ] && echo >&2 " - SuSe based (installer is: zypper)" && opts="zypper ${opts}"
  [ -n "${pacman}" ] && echo >&2 " - Arch Linux based (installer is: pacman)" && opts="pacman ${opts}"
  [ -n "${emerge}" ] && echo >&2 " - Gentoo based (installer is: emerge)" && opts="emerge ${opts}"
  [ -n "${equo}" ] && echo >&2 " - Sabayon based (installer is: equo)" && opts="equo ${opts}"
  [ -n "${apk}" ] && echo >&2 " - Alpine Linux based (installer is: apk)" && opts="apk ${opts}"
  [ -n "${swupd}" ] && echo >&2 " - Clear Linux based (installer is: swupd)" && opts="swupd ${opts}"
  [ -n "${brew}" ] && echo >&2 " - macOS based (installer is: brew)" && opts="brew ${opts}"
  # XXX: This is being removed in another PR.
  echo >&2

  REPLY=
  while [ -z "${REPLY}" ]; do
    echo "To proceed please write one of these:"
    echo "${opts// /, }"
    if ! read -r -p ">" REPLY; then
      continue
    fi

    if [ "${REPLY}" = "yum" ] && [ -z "${distribution}" ]; then
      REPLY=
      while [ -z "${REPLY}" ]; do
        if ! read -r -p "yum in centos, rhel or fedora? > "; then
          continue
        fi

        case "${REPLY,,}" in
          fedora | rhel)
            distribution="rhel"
            ;;
          centos)
            distribution="centos"
            ;;
          *)
            echo >&2 "Please enter 'centos', 'fedora' or 'rhel'."
            REPLY=
            ;;
        esac
      done
      REPLY="yum"
    fi
    check_package_manager "${REPLY}" || REPLY=
  done
}

detect_package_manager_from_distribution() {
  case "${1,,}" in
    arch* | manjaro* | endeavouros*)
      package_installer="install_pacman"
      tree="arch"
      if [ -z "${pacman}" ]; then
        log_error "command 'pacman' is required to install packages on a '${distribution} ${version}' system."
        exit 1
      fi
      ;;

    alpine*)
      package_installer="install_apk"
      tree="alpine"
      if [ -z "${apk}" ]; then
        log_error "command 'apk' is required to install packages on a '${distribution} ${version}' system."
        exit 1
      fi
      ;;

    debian* | ubuntu*)
      package_installer="install_apt_get"
      tree="debian"
      if [ -z "${apt_get}" ]; then
        log_error "command 'apt-get' is required to install packages on a '${distribution} ${version}' system."
        exit 1
      fi
      ;;

    centos* | clearos*)
      echo >&2 "You should have EPEL enabled to install all the prerequisites."
      echo >&2 "Check: http://www.tecmint.com/how-to-enable-epel-repository-for-rhel-centos-6-5/"
      package_installer="install_yum"
      tree="centos"
      if [ -z "${yum}" ]; then
        log_error "command 'yum' is required to install packages on a '${distribution} ${version}' system."
        exit 1
      fi
      ;;

    fedora* | redhat* | red\ hat* | rhel*)
      package_installer=
      tree="rhel"
      [ -n "${yum}" ] && package_installer="install_yum"
      [ -n "${dnf}" ] && package_installer="install_dnf"
      if [ -z "${package_installer}" ]; then
        log_error "command 'yum' or 'dnf' is required to install packages on a '${distribution} ${version}' system."
        exit 1
      fi
      ;;

    macos)
      package_installer="install_brew"
      tree="macos"
      if [ -z "${brew}" ]; then
        log_error "command 'brew' is required to install packages on a '${distribution} ${version}' system."
        exit 1
      fi
      ;;

    *)
      # oops! unknown system
      user_picks_distribution
      ;;
  esac
}

get_os_release() {
  # Loads the /etc/os-release or /usr/lib/os-release file(s)
  # Only the required fields are loaded
  #
  # If it manages to load a valid os-release, it returns 0
  # otherwise it returns 1
  #
  # It searches the ID_LIKE field for a compatible distribution

  os_release_file=
  if [ -s "/etc/os-release" ]; then
    os_release_file="/etc/os-release"
  elif [ -s "/usr/lib/os-release" ]; then
    os_release_file="/usr/lib/os-release"
  else
    echo >&2 "Cannot find an os-release file ..."
    return 1
  fi

  local x
  echo >&2 "Loading ${os_release_file} ..."

  eval "$(grep -E "^(NAME|ID|ID_LIKE|VERSION|VERSION_ID)=" "${os_release_file}")"
  for x in "${ID}" ${ID_LIKE}; do
    case "${x,,}" in
      alpine | arch | centos | clear-linux-os | debian | fedora | gentoo | manjaro | opensuse-leap | rhel | sabayon | sles | suse | ubuntu | endeavouros)
        distribution="${x}"
        version="${VERSION_ID}"
        codename="${VERSION}"
        detection="${os_release_file}"
        break
        ;;
      *)
        echo >&2 "Unknown distribution ID: ${x}"
        ;;
    esac
  done
  [ -z "${distribution}" ] && echo >&2 "Cannot find valid distribution in: ${ID} ${ID_LIKE}" && return 1

  [ -z "${distribution}" ] && return 1
  return 0
}

get_lsb_release() {
  # Loads the /etc/lsb-release file
  # If it fails, it attempts to run the command: lsb_release -a
  # and parse its output
  #
  # If it manages to find the lsb-release, it returns 0
  # otherwise it returns 1

  if [ -f "/etc/lsb-release" ]; then
    echo >&2 "Loading /etc/lsb-release ..."
    local DISTRIB_ID="" DISTRIB_RELEASE="" DISTRIB_CODENAME=""
    eval "$(grep -E "^(DISTRIB_ID|DISTRIB_RELEASE|DISTRIB_CODENAME)=" /etc/lsb-release)"
    distribution="${DISTRIB_ID}"
    version="${DISTRIB_RELEASE}"
    codename="${DISTRIB_CODENAME}"
    detection="/etc/lsb-release"
  fi

  if [ -z "${distribution}" ] && [ -n "${lsb_release}" ]; then
    echo >&2 "Cannot find distribution with /etc/lsb-release"
    echo >&2 "Running command: lsb_release ..."
    eval "declare -A release=( $(lsb_release -a 2> /dev/null | sed -e "s|^\(.*\):[[:space:]]*\(.*\)$|[\1]=\"\2\"|g") )"
    distribution="${release["Distributor ID"]}"
    version="${release[Release]}"
    codename="${release[Codename]}"
    detection="lsb_release"
  fi

  [ -z "${distribution}" ] && echo >&2 "Cannot find valid distribution with lsb-release" && return 1
  return 0
}

find_etc_any_release() {
  # Check for any of the known /etc/x-release files
  # If it finds one, it loads it and returns 0
  # otherwise it returns 1

  if [ -f "/etc/arch-release" ]; then
    release2lsb_release "/etc/arch-release" && return 0
  fi

  if [ -f "/etc/centos-release" ]; then
    release2lsb_release "/etc/centos-release" && return 0
  fi

  if [ -f "/etc/redhat-release" ]; then
    release2lsb_release "/etc/redhat-release" && return 0
  fi

  if [ -f "/etc/SuSe-release" ]; then
    release2lsb_release "/etc/SuSe-release" && return 0
  fi

  return 1
}

autodetect_distribution() {
  # autodetection of distribution
  get_os_release || get_lsb_release || find_etc_any_release
}

function dotfiles() {
  /usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME $@
}

# Installers
install_pacman() {
  # download the latest package info
  if [ "${DRYRUN}" -eq 1 ]; then
    echo >&2 " >> IMPORTANT << "
    echo >&2 "    Please make sure your system is up to date"
    echo >&2 "    by running:  ${sudo} pacman -Syu  "
    echo >&2
  fi

  # install the required packages
  if [ "${NON_INTERACTIVE}" -eq 1 ]; then
    echo >&2 "Running in non-interactive mode"
    # http://unix.stackexchange.com/questions/52277/pacman-option-to-assume-yes-to-every-question/52278
    # Try the noconfirm option, if that fails, go with the legacy way for non-interactive
    sudo pacman --noconfirm --needed -S "${@}" || yes | run ${sudo} pacman --needed -S "${@}"
  else
    sudo pacman --needed -S "${@}"
  fi
}

install_apt_get() {
  local opts=""
  if [ "${NON_INTERACTIVE}" -eq 1 ]; then
    echo >&2 "Running in non-interactive mode"
    # http://serverfault.com/questions/227190/how-do-i-ask-apt-get-to-skip-any-interactive-post-install-configuration-steps
    export DEBIAN_FRONTEND="noninteractive"
    opts="${opts} -yq"
  fi

  read -r -a apt_opts <<< "$opts"

  # update apt repository caches
  echo >&2 "NOTE: Running apt-get update and updating your APT caches ..."
  sudo apt-get "${apt_opts[@]}" update

  # install the required packages
  sudo apt-get "${apt_opts[@]}" install "${@}"
}

install_yum() {
  # download the latest package info
  if [ "${DRYRUN}" -eq 1 ]; then
    echo >&2 " >> IMPORTANT << "
    echo >&2 "    Please make sure your system is up to date"
    echo >&2 "    by running:  ${sudo} yum update  "
    echo >&2
  fi

  local opts=
  if [ "${NON_INTERACTIVE}" -eq 1 ]; then
    echo >&2 "Running in non-interactive mode"
    # http://unix.stackexchange.com/questions/87822/does-yum-have-an-equivalent-to-apt-aptitudes-debian-frontend-noninteractive
    opts="-y"
  fi

  read -r -a yum_opts <<< "${opts}"

  # install the required packages
  sudo yum "${yum_opts[@]}" install "${@}" # --enablerepo=epel-testing
}

install_apk() {
  # download the latest package info
  if [ "${DRYRUN}" -eq 1 ]; then
    echo >&2 " >> IMPORTANT << "
    echo >&2 "    Please make sure your system is up to date"
    echo >&2 "    by running:  ${sudo} apk update  "
    echo >&2
  fi

  local opts="--force-broken-world"
  if [ "${NON_INTERACTIVE}" -eq 1 ]; then
    echo >&2 "Running in non-interactive mode"
  else
    opts="${opts} -i"
  fi

  read -r -a apk_opts <<< "$opts"

  # install the required packages
  sudo apk add "${apk_opts[@]}" "${@}"
}

install_brew() {
  # download the latest package info
  if [ "${DRYRUN}" -eq 1 ]; then
    echo >&2 " >> IMPORTANT << "
    echo >&2 "    Please make sure your system is up to date"
    echo >&2 "    by running:  brew upgrade "
    echo >&2
  fi

  brew install "${@}"
}


##################
#      MAIN      #
##################

if [ -z "${package_installer}" ] || [ -z "${tree}" ]; then
  if [ -z "${distribution}" ]; then
    # we dont know the distribution
    autodetect_distribution || user_picks_distribution
  fi

  # When no package installer is detected, try again from distro info if any
  if [ -z "${package_installer}" ]; then
    detect_package_manager_from_distribution "${distribution}"
  fi
fi

[ "${detection}" = "/etc/os-release" ] && cat << EOF

/etc/os-release information:
NAME            : ${NAME}
VERSION         : ${VERSION}
ID              : ${ID}
ID_LIKE         : ${ID_LIKE}
VERSION_ID      : ${VERSION_ID}
EOF

cat << EOF

We detected these:
Distribution    : ${distribution}
Version         : ${version}
Codename        : ${codename}
Package Manager : ${package_installer}
Packages Tree   : ${tree}
Detection Method: ${detection}

EOF


info "${BOLD} Bootstrapping...${NO_COLOR}\n\n"

setup() {
  info "Cloning ndom91/dotfiles into bare repo at ~/"
  git clone --quiet --bare https://github.com/ndom91/dotfiles.git $HOME/dotfiles

  if [ $? -ne 0 ]; then
    warn "Error cloning repo, trying again..."
    dotfiles clean -n -f | egrep -Eo '\.+[a-zA-Z1-9_./]+' | xargs -I{} mv {}{,.bak}
    git clone --quiet --bare https://github.com/ndom91/dotfiles.git $HOME/dotfiles 2> /dev/null
  fi

  dotfiles checkout

  if [ $? -eq 0 ]; then
    complete "Checked out config."
  else
    warn "Existing files blocking git checkout"
    info "Backing up existing files"
    until dotfiles checkout 2>&1; do
      dotfiles checkout 2>&1 | egrep -Eo '\.+[a-zA-Z1-9_./]+' | xargs -I{} mv {}{,.bak}
    done
  fi

  dotfiles checkout
  info "Setting dotfiles alias and config settings"
  dotfiles config status.showUntrackedFiles no
  info "Sourcing new .bashrc"
  source "$HOME/.bashrc"
}

if not_installed git; then
  ask_for_sudo
  "${package_installer}" git
fi

setup

complete "Dotfiles setup script complete!"
info "To continue, use '$HOME/dotfiles/setup/deploy.sh' to install other package bundles!"

