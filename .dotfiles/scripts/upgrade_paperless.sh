#!/usr/bin/env bash

#########################################
#
#   Paperless Update Script
#   Author: ndomino
#   Update: 06.05.2023
#
#   Usage: sudo ./upgrade_paperless.sh [version_number]
#    i.e.: sudo ./upgrade_paperless.sh 3.1.0
#
#########################################

#### Helper Functions
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

function _spinner() {
    # https://github.com/tlatsas/bash-spinner
    # $1 start/stop
    #
    # on start: $2 display message
    # on stop : $2 process exit status
    #           $3 spinner function pid (supplied from stop_spinner)

    local on_success="DONE"
    local on_fail="FAIL"
    local white="\e[1;37m"
    local green="\e[1;32m"
    local red="\e[1;31m"
    local nc="\e[0m"

    case $1 in
        start)
            # calculate the column where spinner and status msg will be displayed
            let column=$(tput cols)-${#2}-8
            # display message and position the cursor in $column column
            echo -ne "${BOLD}${BLUE}>${NO_COLOR} ${2}"
            printf "%${column}s"

            # start spinner
            i=1
            sp='\|/-'
            delay=${SPINNER_DELAY:-0.15}

            while :
            do
                printf "\b${sp:i++%${#sp}:1}"
                sleep "$delay"
            done
            ;;
        stop)
            if [[ -z ${3} ]]; then
                echo "spinner is not running.."
                exit 1
            fi

            kill "$3" > /dev/null 2>&1

            # inform the user uppon success or failure
            echo -en "\b["
            if [[ $2 -eq 0 ]]; then
                echo -en "${green}${on_success}${nc}"
            else
                echo -en "${red}${on_fail}${nc}"
            fi
            echo -e "]"
            ;;
        *)
            echo "invalid argument, try {start/stop}"
            exit 1
            ;;
    esac
}

function start_spinner {
    # $1 : msg to display
    _spinner "start" "${1}" &
    # set global spinner pid
    _sp_pid=$!
    disown
}

function stop_spinner {
    # $1 : command exit status
    _spinner "stop" "$1" $_sp_pid
    unset _sp_pid
}

#### Initial Checks
# Must be root
[ "$UID" -eq 0 ] || { echo "This script must be run as root."; exit 1;}

# Must pass valid Paperless-ngx version as first argument
if [ ! "$1" ] || [[ ! $1 =~ ^[0-9]+.[0-9]+(.[0-9]+)?$ ]]; then
  echo "You must pass a valid version of the Paperless-ngx i.e. 'sudo ./upgrade_paperless.sh 1.14.4'"
  exit 1
fi

# Variables
VERSION="$1"
PATH_PREFIX=/opt
NEW_PAPERLESS="paperless-v$VERSION"
NEW_PAPERLESS_PATH="$PATH_PREFIX/$NEW_PAPERLESS"
OLD_PAPERLESS_PATH="$PATH_PREFIX/paperless"
DATE=$(date +%d%m%Y)
PAPERLESS_USER=paperless
PAPERLESS_GROUP=paperless

#### Begin installation

start_spinner "Unpacking and Downloading $VERSION " 

# Download requested version
# sudo wget -q "https://github.com/netbox-community/netbox/archive/v$VERSION.tar.gz" "$PATH_PREFIX/v$VERSION.tar.gz" > /dev/null
sudo wget -q "https://github.com/paperless-ngx/paperless-ngx/releases/download/v1.14.4/paperless-ngx-v$VERSION.tar.xz" > /dev/null

sudo tar -xf "paperless-ngx-v$VERSION.tar.xz" > /dev/null
mv "$PATH_PREFIX/paperless-ngx" "$PATH_PREFIX/$NEW_PAPERLESS"

stop_spinner $?

start_spinner "Stopping all paperless services" 

# Stop existing paperless service
sudo systemctl stop \
 paperless-consumer \
 paperless-scheduler \
 paperless-task-queue \
 paperless-webserver

stop_spinner $?

start_spinner "Setting up new directory" 

# Setup new directories
sudo chown -R "$PAPERLESS_USER":"$PAPERLESS_GROUP" "$NEW_PAPERLESS_PATH"
cp "$OLD_PAPERLESS_PATH/paperless.conf" "$NEW_PAPERLESS_PATH/"
cp -r "$OLD_PAPERLESS_PATH/media" "$NEW_PAPERLESS_PATH/"
cp -r "$OLD_PAPERLESS_PATH/data" "$NEW_PAPERLESS_PATH/"
cp -r "$OLD_PAPERLESS_PATH/consume" "$NEW_PAPERLESS_PATH/"

# Currently unused
if [ -f "$OLD_PAPERLESS_PATH/gunicorn.py" ]; then
  cp "$OLD_PAPERLESS_PATH/gunicorn.py" "$NEW_PAPERLESS_PATH/"
fi
if [ -f "$OLD_PAPERLESS_PATH/local_requirements.txt" ]; then
  cp "$OLD_PAPERLESS_PATH/local_requirements.txt" "$NEW_PAPERLESS_PATH/"
fi

# Delete old symlink
sudo rm "$OLD_PAPERLESS_PATH"

# Create new symlink
sudo ln -s "$NEW_PAPERLESS_PATH" "$OLD_PAPERLESS_PATH"

stop_spinner $?

start_spinner "Upgrading Paperless-ngx packages" 

cd "$NEW_PAPERLESS_PATH"
sudo -Hu paperless python3 -m venv venv
source venv/bin/activate
sudo -Hu paperless pip install --no-warn-script-location -r requirements.txt > /dev/null
cd "$NEW_PAPERLESS_PATH/src"
sudo -Hu paperless python3 manage.py migrate

stop_spinner $?

# If install successful, clean-up
if [ $? -eq 0 ]; then
  start_spinner "Cleaning up and restarting Paperless " 

  sudo rm "/opt/paperless-ngx-v$VERSION.tar.xz"
  sudo chown -R "$PAPERLESS_USER":"$PAPERLESS_GROUP" "$NEW_PAPERLESS_PATH"

  sudo systemctl start \
   paperless-consumer \
   paperless-scheduler \
   paperless-task-queue \
   paperless-webserver

  stop_spinner $?

  complete "Upgrade to $VERSION successfully completed"
else
  error "Error in Upgrade Script, please check output above for errors!"
fi

