#!/usr/bin/env bash
set -uf -o pipefail

###############################################################################
#
#                   Checkly Local Dev Tmux Script
#
#                 ..         .:-====--:          .
#              .#%##%%+. -+%%##@@@@@@%##%*=. -*%###%+
#              %#-+**=#@%#+=====*@@#======*%@@+=**==@=
#              #%-*@@@*:....::-==+*===-:.....=%@@@==@-
#               %%+@*.   ...    :===:    ..    -@#+@+       .
#                #@:  .+%@@@@+   .-   :#@@@@#=   *@-  .=*%@@@@+
#               ##   *@@%-::+@*      .@@-:.=@@@-  =@+%#**%%@@%@-
#              #%   #@%@##@@@@@. ... =@%@@@*%@%@-  -@+-====+*%@%
#             *@-  .@@@@@@@@%@%  *%: :@%@@@@@@%@#   *@*+=====-*@.
#            -@+-*- =%@@@@@@@*. *#%#- -%@@@@@@%*. +=-#@@@%*===+@.
#            %#-=+%*.  ...::     :-.    .::..   -%#==+@@@@@@%++@
#           :@+====+%#=*%%##@+        .#%##%#++%#=====#@@@@@@@@#
#           =@+====+#%*+=====@-       #%-====+#%*=====%@=*@@@%@-
#           =@%#====+=======%%--------+@*=======+===+%@@===#@@#
#           -@=*%#*+====+*%%*====---====#@#+====++#%%=#%===-#%
#            @*-==*######*===:.       .-==+*#####*+===@@+==#%.
#            =@============:            .-==========-#@@@*%*
#             *@#%##%%#+==.               -==*%%##%%#@@%@%-
#              @*-====+%%:                 +@#======%@@%=
#             .@+=-...:=*@.               =@+-:...==#%-
#              +@+     .=@+               @#-     :#@.
#               :%#-   .*@:               *@=   .=%*.
#                 :+##%#*##+=-:.    ..:-+*%**%##*=
#                          .-=++****++=-:
#
#   Author:  Nico Domino
#   Usage:  Make sure the variables match your local setup.
#
###############################################################################

### USER VARIABLES ###
# Define base directory where you cloned your Checkly repositories
# i.e. $CHECKLY_DIR/checkly-backend, $CHECKLY_DIR/checkly-webapp should exist
CHECKLY_DIR="/opt/checkly"
###

PROGRAM=$(basename "$0")
LIGHTBLUE="$(printf '\e[96m')"
GREEN="$(printf '\e[32m')"
YELLOW="$(printf '\e[33m')"
RED="$(printf '\e[31m')"
BOLD="$(printf '\e[1m')"
RESET="$(printf '\e[0m')"

usage() {
  echo ""
  echo "Usage:"
  echo ""
  echo -e "  ${LIGHTBLUE}$PROGRAM${RESET} [-hsrfb]"
  echo ""
  echo "  -h, --help, help          print this message"
  echo "  -s, --status, status      check status of dev processes"
  echo "  -r, --restart, restart    restart checkly dev processes"
  echo "    (-r -f to restart frontend only)"
  echo "    (-r -b to restart backend only)"
  echo "    (-r -c to restart containers only)"
  echo "  -S, --stop, stop          kill checkly dev processes"
  echo "  -a, --all, all            run all check dev components"
  echo "  -f, --frontend, frontend  run check-webapp vue frontend"
  echo "  -b, --backend, backend    run checkly-backend api/functions/daemons"
  echo ""
  echo -e "  see ${LIGHTBLUE}Checkly${RESET} Notion for more details"
  echo ""
  echo -e "  You need the following three repos:"
  echo -e "  ${LIGHTBLUE}checkly${RESET}/checkly-backend"
  echo -e "  ${LIGHTBLUE}checkly${RESET}/checkly-lambda-runners"
  echo -e "  ${LIGHTBLUE}checkly${RESET}/checkly-webapp"
  echo ""
  exit 0
}

start() {
  frontend() {
    tmux neww -t checkly: -n webapp -d "cd $CHECKLY_DIR/checkly-webapp && npm run serve"
  }
  backend() {
    tmux neww -t checkly: -n api -d "cd $CHECKLY_DIR/checkly-backend/api && npm run start:watch"
    tmux neww -t checkly: -n functions -d "cd $CHECKLY_DIR/checkly-lambda-runners/functions && npm run start:local"
    tmux neww -t checkly: -n daemons -d "cd $CHECKLY_DIR/checkly-backend/api && npm run start:all-daemons:watch"
  }

  if ! tmux has-session -t checkly 2>/dev/null; then
    tmux new -s checkly -d
  fi

  for arg in "$@"; do
    case $arg in
    frontend)
      echo -e "[*] Starting ${LIGHTBLUE}Checkly${RESET} Frontend Dev Environment.."
      frontend
      exit 0
      ;;
    backend)
      echo -e "[*] Starting ${LIGHTBLUE}Checkly${RESET} Backend Dev Environment.."
      backend
      exit 0
      ;;
    all)
      echo -e "[*] Starting ${LIGHTBLUE}Checkly${RESET} Development Environment.."
      backend
      frontend
      exit 0
      ;;
    esac
  done
}

checkContainers() {
  running="$(docker inspect --format="{{.State.Running}}" $(docker container ls -q --filter name=devenv) 2>/dev/null | wc -l)"
  echo $running
}

checkTmux() {
  if tmux has-session -t checkly 2>/dev/null; then
    true
  else
    false
  fi
}

# Check if vital dependencies are met
if [ ! "$(command -v tmux)" ]; then
  echo -e "[${RED}Error${RESET}] Please install tmux before continuing!"
  exit 1
fi

if [ ! "$(command -v docker)" ] || [ ! "$(command -v docker-compose)" ]; then
  echo -e "[${RED}Error${RESET}] Please install docker and docker-compose before continuing!"
  exit 1
fi

# Check to ensure atleast some arguments are passed
if [ $# -eq 0 ]; then
  echo ""
  echo "No arguments passed. Please check usage below.."
  usage
  exit 1
fi

# Main switch statement to determine action based on argument passed
while [ "$#" -gt 0 ]; do
  i=$1
  # echo $i

  case "$i" in
  -h | --help | help)
    usage
    ;;
  -s | --status | status)
    # Check Tmux Windows
    if checkTmux; then
      windows="$(tmux display-message -t checkly -p "#{session_windows}")"
      if [ "$windows" != 5 ] && [ "$windows" != 0 ]; then
        echo -e "[*] ${BOLD}${LIGHTBLUE}Checkly${RESET} tmux ${BOLD}${YELLOW}DEGRADED${RESET} with ${BOLD}$windows${RESET} windows"
      elif [ "$windows" = 5 ]; then
        echo -e "[*] ${BOLD}${LIGHTBLUE}Checkly${RESET} tmux ${BOLD}${GREEN}ACTIVE${RESET} with ${BOLD}$windows${RESET} windows"
      fi
    else
      echo -e "[*] 5 ${BOLD}${LIGHTBLUE}Checkly${RESET} tmux ${BOLD}${RED}INACTIVE${RESET}"
    fi

    # Check Docker Containers
    containerCount=$(checkContainers)

    if [ "$containerCount" -gt 3 ]; then
      echo -e "[*] ${BOLD}${LIGHTBLUE}Checkly${RESET} Docker ${BOLD}${GREEN}ACTIVE${RESET} with ${BOLD}$containerCount${RESET} containers"
    elif [[ containerCount -lt 3 ]] && [[ containerCount -gt 0 ]]; then
      echo -e "[*] ${BOLD}${LIGHTBLUE}Checkly${RESET} Docker ${BOLD}${YELLOW}DEGRADED${RESET} with ${BOLD}$containerCount${RESET} containers"
    elif [[ containerCount -eq 0 ]]; then
      echo -e "[*] ${BOLD}${LIGHTBLUE}Checkly${RESET} Docker ${BOLD}${RED}INACTIVE${RESET}"
    fi
    exit 0
    ;;
  -r | --restart | restart | -rf | -rb | -rc)
    if [[ "$#" > 1 ]] || [[ "$1" =~ -r(f|c|b) ]]; then
      if [[ "$@" == *"f"* ]]; then
        tmux kill-window -t checkly:webapp &>/dev/null
        pkill -f 'node /opt/checkly/checkly-webapp' &>/dev/null
        start frontend
      elif [[ "$@" == *"b"* ]]; then
        echo "[*] Restarting Backend!"
        tmux kill-window -t checkly:api &>/dev/null
        tmux kill-window -t checkly:functions &>/dev/null
        tmux kill-window -t checkly:daemons &>/dev/null
        pkill -f 'node daemons/' &>/dev/null
        pkill -f 'node /opt/checkly/checkly-backend' &>/dev/null
        pkill -f 'node /opt/checkly/checkly-lambda-runners' &>/dev/null
        start backend
      elif [[ "$@" == *"c"* ]]; then
        echo "[*] Restarting containers!"
        containerCount=$(checkContainers)
        docker container restart $(docker container ls -a -q --filter name=devenv*) 1>/dev/null
      fi
      exit 0
    fi
    if checkTmux; then
      echo -e "[*] Stopping ${LIGHTBLUE}Checkly${RESET} API, Functions, Daemons and Webapp.."
      tmux kill-session -t checkly
    else
      echo -e "[*] No tmux session named ${LIGHTBLUE}checkly${RESET}!"
    fi
    containerCount=$(checkContainers)
    if [ "$containerCount" -gt 0 ]; then
      read -r -p "[*] Restart Docker containers? [y/N] " response
      if [ "$response" != "${response#[Yy]}" ]; then
        docker container restart $(docker container ls -a -q --filter name=devenv*) 1>/dev/null
      fi
    fi
    start all
    ;;
  -S | --stop | stop)
    containerCount=$(checkContainers)
    if [ "$containerCount" -gt 0 ]; then
      read -r -p "[*] Stop Docker containers? [y/N] " response
      if [ "$response" != "${response#[Yy]}" ]; then
        docker container stop $(docker container ls -a -q --filter name=devenv*) 1>/dev/null
      fi
    fi
    if ! checkTmux; then
      echo -e "[*] No tmux session named ${LIGHTBLUE}checkly${RESET}. Exiting.."
      exit 0
    fi
    echo "[*] Stopping all tmux windows / sessions.."
    tmux kill-session -t checkly
    exit 0
    ;;
  -a | --all | all)
    start all
    ;;
  -b | --backend | backend)
    echo "Starting Backend!"
    start backend
    ;;
  -f | --frontend | frontend)
    start frontend
    ;;
  *)
    echo "Command Unknown $i"
    shift
    ;;
  esac
done
