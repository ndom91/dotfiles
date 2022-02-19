#!/usr/bin/env bash
#             .___             ________  ____
#   ____    __| _/____   _____/   __   \/_   |
#  /    \  / __ |/  _ \ /     \____    / |   |
# |   |  \/ /_/ (  |_| )  Y Y  \ /    /  |   |
# |___|  /\____ |\____/|__|_|  //____/   |___|
#      \/      \/            \/
#
# DOTFILES INIT SCRIPT
# Updated: 28.08.21
#

# shellcheck source=../utils/helpers.sh
. ../utils/helpers.sh
# shellcheck source=../utils/utils.sh
. ../utils/utils.sh
# shellcheck source=../utils/logging.sh
. ../utils/logging.sh


function display_help() {
  cat <<EOF
  $(help_title_section Usage)
    ${PROGRAM} [options] [<command>]
  $(help_title_section Commands)
    check
    packages [--repo | --aur]
    modules
    update
    clean
  $(help_title_section Options)
    -h --help         Show this screen.
    -v --version      Show version.
EOF
}


if [ -z "${package_installer}" ]; then
  if [ -z "${distribution}" ]; then
    # we dont know the distribution
    autodetect_distribution || user_picks_distribution
  fi

  # When no package installer is detected, try again from distro info if any
  if [ -z "${package_installer}" ]; then
    detect_package_manager_from_distribution "${distribution}"
  fi
fi

# DEBUG OUTPUT
# [ "${detection}" = "/etc/os-release" ] && cat << EOF
#
# /etc/os-release information:
# NAME            : ${NAME}
# VERSION         : ${VERSION}
# ID              : ${ID}
# ID_LIKE         : ${ID_LIKE}
# VERSION_ID      : ${VERSION_ID}
#
# EOF
#
# cat << EOF
#
# We detected these:
# Distribution    : ${distribution}
# Version         : ${version}
# Codename        : ${codename}
# Package Manager : ${package_installer}
# Packages Tree   : ${tree}
# Detection Method: ${detection}
#
# EOF

execute "which rsgsg" "Listing ~dotfiles"

exit 0

function dotfiles() {
  /usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME $@
}

##################
#      MAIN      #
##################

printf "${BOLD} Welcome to your init script, Nico!${NO_COLOR}\n\n"

setup() {
  start_spinner "${BOLD}${GREY}>${NO_COLOR} Cloning ndom91/dotfiles into bare repo at ~/"

  if ! [ "git clone --quiet --bare https://github.com/ndom91/dotfiles.git $HOME/dotfiles" ]; then
    dotfiles clean -n -f | egrep -Eo '\.+[a-zA-Z1-9_./]+' | xargs -I{} mv {}{,.bak}
    git clone --quiet --bare https://github.com/ndom91/dotfiles.git $HOME/dotfiles >>/dev/null
  fi

  stop_spinner $?

  dotfiles checkout

  if [ $? -eq 0 ]; then
    complete 'Checked out config.'
  else
    warn 'Existing files blocking git checkout'
    start_spinner "${BOLD}${GREY}>${NO_COLOR} Backing up existing files"
    until dotfiles checkout 2>&1; do
      dotfiles checkout 2>&1 | egrep -Eo '\.+[a-zA-Z1-9_./]+' | xargs -I{} mv {}{,.bak}
    done
    stop_spinner $?
  fi

  dotfiles checkout
  info 'Setting dotfiles alias and config settings'
  dotfiles config status.showUntrackedFiles no
  info 'Sourcing new .bashrc'
  source ~/.bashrc
}

if ! [ -x "$(command -v git)" ]; then
  # check_root
  sudo $pkgMgr install -y -q git >/dev/null 2>&1
fi

setup

if [[ -n ${VIM} ]]; then
  info 'Deploying vim setup script'
  ./deploy.sh vim
fi

printf '\n'
complete 'Dotfiles setup script complete!'
