#!/usr/bin/env bash

#########################################
#
#   NewTelco GmbH Netbox Update Script
#   Author: ndomino
#   Update: 10.12.2021
#
#   Usage: sudo ./upgrade_netbox.sh [version_number]
#    i.e.: sudo ./upgrade_netbox.sh 3.1.0
#
#########################################

[ "$UID" -eq 0 ] || { echo "This script must be run as root."; exit 1;}

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
            echo -ne "${2}"
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

##### VARIABLES #####

if [ ! "$1" ]; then
  echo "You must pass the new version of the Netbox i.e. 'sudo ./upgrade_netbox.sh 2.8.9'"
  exit 1
fi

NEW_NETBOX="netbox-$1"
DATE=$(date +%d%m%Y)

start_spinner "${BOLD}${BLUE}>${NO_COLOR} Unpacking and Downloading $1 " 

sudo wget -q "https://github.com/netbox-community/netbox/archive/v$1.tar.gz" "/opt/v$1.tar.gz" > /dev/null
sudo tar -xf "v$1.tar.gz" > /dev/null

stop_spinner $?

start_spinner "${BOLD}${BLUE}>${NO_COLOR} Stopping 'netbox' and 'netbox-rq'" 

# sudo systemctl stop netbox netbox-rq netbox-pdu
sudo systemctl stop netbox netbox-rq

stop_spinner $?

start_spinner "${BOLD}${BLUE}>${NO_COLOR} Setting up new directory" 

sudo chown -R netbox: /opt/"$NEW_NETBOX"

cp /opt/netbox/netbox/netbox/configuration.py /opt/"$NEW_NETBOX"/netbox/netbox/
cp /opt/netbox/netbox/netbox/ldap_config.py /opt/"$NEW_NETBOX"/netbox/netbox/
cp /opt/netbox/gunicorn.py /opt/"$NEW_NETBOX"/
cp /opt/netbox/local_requirements.txt /opt/"$NEW_NETBOX"/
cp -r /opt/netbox/netbox/media/* /opt/"$NEW_NETBOX"/netbox/media/

cp -r /opt/netbox/netbox/scripts/* /opt/"$NEW_NETBOX"/netbox/scripts/
cp -r /opt/netbox/netbox/reports/* /opt/"$NEW_NETBOX"/netbox/reports/

sudo rm /opt/netbox

sudo ln -s /opt/"$NEW_NETBOX" /opt/netbox

stop_spinner $?

start_spinner "${BOLD}${BLUE}>${NO_COLOR} Running Netbox upgrade script " 

"/opt/$NEW_NETBOX/upgrade.sh" >> "/opt/$NEW_NETBOX/upgrade_$DATE.log" 2>&1

mkdir -p "/opt/$NEW_NETBOX/logs"

stop_spinner $?

if [ $? -eq 0 ]; then
  start_spinner "${BOLD}${BLUE}>${NO_COLOR} Cleaning up and restarting Netbox " 

  sudo rm /opt/v"$1".tar.gz
  sudo chown -R netbox: /opt/"$NEW_NETBOX"
  # sudo sed 's/SAMEORIGIN/ALLOW FROM https:\/\/wiki.newtelco.de\//' /opt/"$NEW_NETBOX"/netbox/netbox/settings.py 
  sudo patch -s -p1 /opt/"$NEW_NETBOX"/netbox/netbox/settings.py < /opt/wiki_settings.patch
  sudo systemctl start netbox netbox-rq

  stop_spinner $?

  complete "Upgrade to $1 successfully completed"
else
  error "Error in Upgrade Script, please check output above for errors!"
  error "Netbox upgrade script output was also logged to $NEW_NETBOX/upgrade_$DATE.log"
fi

