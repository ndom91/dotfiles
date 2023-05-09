#!/usr/bin/env bash

#########################################
#
#   Netbox Update Script
#   Author: ndomino
#   Update: 28.04.2022
#
#   Usage: sudo ./upgrade_netbox.sh [version_number]
#    i.e.: sudo ./upgrade_netbox.sh 3.1.0
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

# Must pass valid Netbox version as first argument
if [ ! "$1" ] || [[ ! $1 =~ ^[0-9]+.[0-9]+(.[0-9]+)?$ ]]; then
  echo "You must pass a valid version of the Netbox i.e. 'sudo ./upgrade_netbox.sh 2.8.9'"
  exit 1
fi

# Variables
VERSION="$1"
NEW_NETBOX="netbox-$VERSION"
DATE=$(date +%d%m%Y)
NETBOX_USER=netbox
NETBOX_GROUP=netbox
PATH_PREFIX=/opt

#### Begin installation

start_spinner "Unpacking and Downloading $VERSION " 

# Download requested version
sudo wget -q "https://github.com/netbox-community/netbox/archive/v$VERSION.tar.gz" "$PATH_PREFIX/v$VERSION.tar.gz" > /dev/null
sudo tar -xf "v$VERSION.tar.gz" > /dev/null

stop_spinner $?

start_spinner "Stopping 'netbox' and 'netbox-rq'" 

# Stop existing netbox service
sudo systemctl stop netbox netbox-rq

stop_spinner $?

start_spinner "Setting up new directory" 

# Setup new directories
sudo chown -R "$NETBOX_USER":"$NETBOX_GROUP" "$PATH_PREFIX/$NEW_NETBOX"

cp "$PATH_PREFIX"/netbox/netbox/netbox/configuration.py /opt/"$NEW_NETBOX"/netbox/netbox/
if [ -f "$PATH_PREFIX"/netbox/netbox/netbox/ldap_config.py ]; then
  cp "$PATH_PREFIX"/netbox/netbox/netbox/ldap_config.py /opt/"$NEW_NETBOX"/netbox/netbox/
fi
if [ -f "$PATH_PREFIX"/netbox/gunicorn.py ]; then
  cp "$PATH_PREFIX"/netbox/gunicorn.py /opt/"$NEW_NETBOX"/
fi
if [ -f "$PATH_PREFIX"/netbox/local_requirements.txt ]; then
  cp "$PATH_PREFIX"/netbox/local_requirements.txt /opt/"$NEW_NETBOX"/
fi
cp -r "$PATH_PREFIX"/netbox/netbox/media/* /opt/"$NEW_NETBOX"/netbox/media/
cp -r "$PATH_PREFIX"/netbox/netbox/scripts/* /opt/"$NEW_NETBOX"/netbox/scripts/
cp -r "$PATH_PREFIX"/netbox/netbox/reports/* /opt/"$NEW_NETBOX"/netbox/reports/

# Delete old symlink
sudo rm "$PATH_PREFIX"/netbox

# Create new symlink
sudo ln -s "$PATH_PREFIX"/"$NEW_NETBOX" /opt/netbox

stop_spinner $?

start_spinner "Running Netbox upgrade script " 

# Execute netbox upgrade.sh script - save output to log file
"$PATH_PREFIX"/"$NEW_NETBOX"/upgrade.sh >> /opt/"$NEW_NETBOX"/upgrade_"$DATE".log 2>&1

mkdir -p "$PATH_PREFIX"/"$NEW_NETBOX"/logs

stop_spinner $?

# If install successful, clean-up
if [ $? -eq 0 ]; then
  start_spinner "Cleaning up and restarting Netbox " 

  sudo rm "$PATH_PREFIX/v$VERSION".tar.gz
  sudo chown -R "$NETBOX_USER":"$NETBOX_GROUP" "$PATH_PREFIX/$NEW_NETBOX"

  sudo systemctl start netbox netbox-rq

  stop_spinner $?

  complete "Upgrade to $VERSION successfully completed"
else
  error "Error in Upgrade Script, please check output above for errors!"
  error "Netbox upgrade script output was also logged to $NEW_NETBOX/upgrade_$DATE.log"
fi

