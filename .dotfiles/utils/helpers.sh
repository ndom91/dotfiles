#!/usr/bin/env bash

import() {
  local -r SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]:-$0}")

  # shellcheck source=/dev/null
  . "${SCRIPTS_DIR}/${1}"
}

# shellcheck source=./colors.sh
import colors.sh
# shellcheck source=./logging.sh
import logging.sh

# needed commands
lsb_release=$(command -v lsb_release 2> /dev/null)

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

function display_version() {
  local program="${2:-$(basename "$0")}"
  local version=${1:?"You need to give a version number"}

  if [ -x "$(command -v figlet)" ]; then
    echo -n "${BLUE}${BOLD}"
    figlet "${program} script"
    echo -n "${RESET}"
    echo "version ${version}"
  else
    echo "${program} script version ${version}"
  fi
}

function help_title_section() {
  local -r TITLE=$(echo "$@" | tr '[:lower:]' '[:upper:]')
  echo -e "${BOLD}${TITLE}${RESET}"
}

confirm() {
  if [ -z "${FORCE-}" ]; then
    printf "${MAGENTA}?${NO_COLOR} $@ ${BOLD}[yN]${NO_COLOR} "
    read -es yn </dev/tty
    rc=$?
    if [ $rc -ne 0 ]; then
      error "Error reading from prompt (please re-run with the \`--yes\` option)"
      exit 1
    fi
    if [ "$yn" != "y" ] && [ "$yn" != "yes" ]; then
      error "Aborting (please answer \"yes\" to continue)"
      exit 1
    fi
  fi
}

prompt() {
  if [ "${NON_INTERACTIVE}" -eq 1 ]; then
    echo >&2 "Running in non-interactive mode, assuming yes (y)"
    echo >&2 " > Would have prompted for ${1} ..."
    return 0
  fi

  while true; do
    read -r -p "${1} [y/n] " yn
    case $yn in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo >&2 "Please answer with yes (y) or no (n)." ;;
    esac
  done
}

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

get_lsb_release() {
  # Loads the /etc/lsb-release file
  # If it fails, it attempts to run the command: lsb_release -a
  # and parse its output
  #
  # If it manages to find the lsb-release, it returns 0
  # otherwise it returns 1

  if [ -f "/etc/lsb-release" ]; then
    log_info "Loading /etc/lsb-release ..."
    local DISTRIB_ID="" DISTRIB_RELEASE="" DISTRIB_CODENAME=""
    eval "$(grep -E "^(DISTRIB_ID|DISTRIB_RELEASE|DISTRIB_CODENAME)=" /etc/lsb-release)"
    distribution="${DISTRIB_ID}"
    version="${DISTRIB_RELEASE}"
    codename="${DISTRIB_CODENAME}"
    detection="/etc/lsb-release"
  fi

  if [ -z "${distribution}" ] && [ -n "${lsb_release}" ]; then
    log_warn "Cannot find distribution with /etc/lsb-release"
    log_info "Running command: lsb_release ..."
    eval "declare -A release=( $(lsb_release -a 2> /dev/null | sed -e "s|^\(.*\):[[:space:]]*\(.*\)$|[\1]=\"\2\"|g") )"
    distribution="${release["Distributor ID"]}"
    version="${release[Release]}"
    codename="${release[Codename]}"
    detection="lsb_release"
  fi

  [ -z "${distribution}" ] && echo >&2 "Cannot find valid distribution with lsb-release" && return 1
  return 0
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
  log_info "Loading /etc/os-release ..."
  # echo >&2 "Loading ${os_release_file} ..."

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


autodetect_distribution() {
  # autodetection of distribution/OS
  case "$(uname -s)" in
    "Linux")
      get_os_release || get_lsb_release 
      ;;
    "FreeBSD")
      distribution="freebsd"
      version="$(uname -r)"
      detection="uname"
      ;;
    "Darwin")
      distribution="macos"
      version="$(uname -r)"
      detection="uname"

      if [ ${EUID} -eq 0 ]; then
        echo >&2 "This script does not support running as EUID 0 on macOS. Please run it as a regular user."
        exit 1
      fi
      ;;
    *)
      return 1
      ;;
  esac
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

    freebsd)
      package_installer="install_pkg"
      tree="freebsd"
      if [ -z "${pkg}" ]; then
        log_error "command 'pkg' is required to install packages on a '${distribution} ${version}' system."
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

DRYRUN=0
run() {

  printf >&2 "%q " "${@}"
  printf >&2 "\n"

  if [ ! "${DRYRUN}" -eq 1 ]; then
    "${@}"
    return $?
  fi
  return 0
}

# -----------------------------------------------------------------------------
# debian / ubuntu

validate_install_apt_get() {
  echo >&2 " > Checking if package '${*}' is installed..."
  [ "$(dpkg-query -W --showformat='${Status}\n' "${*}")" = "install ok installed" ] || echo "${*}"
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
  if [ "${version}" = 8 ]; then
    echo >&2 "WARNING: You seem to be on Debian 8 (jessie) which is old enough we have to disable Check-Valid-Until checks"
    if ! cat /etc/apt/sources.list /etc/apt/sources.list.d/* 2> /dev/null | grep -q jessie-backports; then
      echo >&2 "We also have to enable the jessie-backports repository"
      if prompt "Is this okay?"; then
        ${sudo} /bin/sh -c 'echo "deb http://archive.debian.org/debian/ jessie-backports main contrib non-free" >> /etc/apt/sources.list.d/99-archived.list'
      fi
    fi
    run ${sudo} apt-get "${apt_opts[@]}" -o Acquire::Check-Valid-Until=false update
  else
    run ${sudo} apt-get "${apt_opts[@]}" update
  fi

  # install the required packages
  run ${sudo} apt-get "${apt_opts[@]}" install "${@}"
}

# -----------------------------------------------------------------------------
# centos / rhel

validate_install_yum() {
  echo >&2 " > Checking if package '${*}' is installed..."
  yum list installed "${*}" > /dev/null 2>&1 || echo "${*}"
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
  run ${sudo} yum "${yum_opts[@]}" install "${@}" # --enablerepo=epel-testing
}

# -----------------------------------------------------------------------------
# fedora

validate_install_dnf() {
  echo >&2 " > Checking if package '${*}' is installed..."
  dnf list installed "${*}" > /dev/null 2>&1 || echo "${*}"
}

install_dnf() {
  # download the latest package info
  if [ "${DRYRUN}" -eq 1 ]; then
    echo >&2 " >> IMPORTANT << "
    echo >&2 "    Please make sure your system is up to date"
    echo >&2 "    by running:  ${sudo} dnf update  "
    echo >&2
  fi

  local opts=
  if [ "${NON_INTERACTIVE}" -eq 1 ]; then
    echo >&2 "Running in non-interactive mode"
    # man dnf
    opts="-y"
  fi

  # install the required packages
  # --setopt=strict=0 allows dnf to proceed
  # installing whatever is available
  # even if a package is not found
  opts="$opts --setopt=strict=0"
  read -r -a dnf_opts <<< "$opts"
  run ${sudo} dnf "${dnf_opts[@]}" install "${@}"
}

# -----------------------------------------------------------------------------
# alpine

validate_install_apk() {
  echo "${*}"
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
  run ${sudo} apk add "${apk_opts[@]}" "${@}"
}

# -----------------------------------------------------------------------------
# arch

PACMAN_DB_SYNCED=0
validate_install_pacman() {

  if [ ${PACMAN_DB_SYNCED} -eq 0 ]; then
    echo >&2 " > Running pacman -Sy to sync the database"
    local x
    x=$(pacman -Sy)
    [ -z "${x}" ] && echo "${*}"
    PACMAN_DB_SYNCED=1
  fi
  echo >&2 " > Checking if package '${*}' is installed..."

  # In pacman, you can utilize alternative flags to exactly match package names,
  # but is highly likely we require pattern matching too in this so we keep -s and match
  # the exceptional cases like so
  local x=""
  case "${package}" in
    "gcc")
      # Temporary workaround: In archlinux, default installation includes runtime libs under package "gcc"
      # These are not sufficient for netdata install, so we need to make sure that the appropriate libraries are there
      # by ensuring devel libs are available
      x=$(pacman -Qs "${*}" | grep "base-devel")
      ;;
    "tar")
      x=$(pacman -Qs "${*}" | grep "local/tar")
      ;;
    "make")
      x=$(pacman -Qs "${*}" | grep "local/make ")
      ;;
    *)
      x=$(pacman -Qs "${*}")
      ;;
  esac

  [ -z "${x}" ] && echo "${*}"
}

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
    run ${sudo} pacman --noconfirm --needed -S "${@}" || yes | run ${sudo} pacman --needed -S "${@}"
  else
    run ${sudo} pacman --needed -S "${@}"
  fi
}

# -----------------------------------------------------------------------------
# macOS

validate_install_pkg() {
  pkg query %n-%v | grep -q "${*}" || echo "${*}"
}

validate_install_brew() {
  brew list | grep -q "${*}" || echo "${*}"
}

install_pkg() {
  # download the latest package info
  if [ "${DRYRUN}" -eq 1 ]; then
    echo >&2 " >> IMPORTANT << "
    echo >&2 "    Please make sure your system is up to date"
    echo >&2 "    by running:  pkg update "
    echo >&2
  fi

  local opts=
  if [ "${NON_INTERACTIVE}" -eq 1 ]; then
    echo >&2 "Running in non-interactive mode"
    opts="-y"
  fi

  read -r -a pkg_opts <<< "${opts}"

  run ${sudo} pkg install "${pkg_opts[@]}" "${@}"
}

install_brew() {
  # download the latest package info
  if [ "${DRYRUN}" -eq 1 ]; then
    echo >&2 " >> IMPORTANT << "
    echo >&2 "    Please make sure your system is up to date"
    echo >&2 "    by running:  brew upgrade "
    echo >&2
  fi

  run brew install "${@}"
}


# Currently known to support:
#   - win (Git Bash)
#   - darwin
#   - linux
#   - linux_musl (Alpine)
detect_platform() {
  local platform="$(uname -s | tr '[:upper:]' '[:lower:]')"

  # check for MUSL
  if [ "${platform}" = "linux" ]; then
    if ldd /bin/sh | grep -i musl >/dev/null; then
      platform=linux_musl
    fi
  fi

  # mingw is Git-Bash
  if echo "${platform}" | grep -i mingw >/dev/null; then
    platform=win
  fi

  echo "${platform}"
}


# Currently known to support:
#   - x64 (x86_64)
#   - x86 (i386)
#   - armv6l (Raspbian on Pi 1/Zero)
#   - armv7l (Raspbian on Pi 2/3)
detect_arch() {
  local arch="$(uname -m | tr '[:upper:]' '[:lower:]')"

  if echo "${arch}" | grep -i arm >/dev/null; then
    # ARM is fine
    echo "${arch}"
  else
    if [ "${arch}" = "i386" ]; then
      arch=x86
    elif [ "${arch}" = "x86_64" ]; then
      arch=x64
    fi

    # `uname -m` in some cases mis-reports 32-bit OS as 64-bit, so double check
    if [ "${arch}" = "x64" ] && [ "$(getconf LONG_BIT)" -eq 32 ]; then
      arch=x86
    fi

    echo "${arch}"
  fi
}

get_distribution() {
	lsb_dist=""
	# Every system that we officially support has /etc/os-release
	if [ -r /etc/os-release ]; then
		lsb_dist="$(. /etc/os-release && echo "$ID")"
	fi
	# Returning an empty string here should be alright since the
	# case statements don't act unless you provide an actual value
	echo "$lsb_dist"
}



[ "$0" = "${BASH_SOURCE[0]}" ] && display_version 0.0.1 || true

