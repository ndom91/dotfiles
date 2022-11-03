#
#  _ __   __| | ___  _ __ ___ / _ \/ |
# | '_ \ / _` |/ _ \| '_ ` _ \ (_) | |
# | | | | (_| | (_) | | | | | \__, | |
# |_| |_|\__,_|\___/|_| |_| |_| /_/|_|
#
# author: Nico Domino
# github: ndom91
#
# https://github.com/ndom91/dotfiles
# Using many `sensible-bash` options
# See: https://github.com/mrzool/bash-sensible

# DEFAULTS
if [[ "$(command -v nvim)" ]]; then
  export EDITOR=nvim
elif [[ "$(command -v vim)" ]]; then
  export EDITOR=vim
else
  export EDITOR=vi
fi
export PAGER="less -R"
export READER="zathura"
export BROWSER="brave"
export VIDEO="vlc"
export XDG_CONFIG_HOME="$HOME/.config"
export BAT_THEME="Coldark-Dark"
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# GUI
# if [ -n "$XDG_CURRENT_DESKTOP" ]; then
#   export QT_QPA_PLATFORMTHEME='gtk2'
#   export QT_STYLE_OVERRIDE='gtk2'
# fi

# If not in an interactive shell return
[[ $- != *i* ]] && return

# Bash Options
shopt -s checkwinsize
shopt -s cdspell
shopt -s autocd
shopt -s dirspell
shopt -s direxpand

CDPATH=".:/opt/"

# sensible-bash
PROMPT_DIRTRIM=2
set -o noclobber
bind Space:magic-space
shopt -s globstar 2>/dev/null
shopt -s nocaseglob
bind "set completion-ignore-case on"
bind "set completion-map-case on"
bind "set show-all-if-ambiguous on"
bind "set mark-symlinked-directories on"

# tab complete for sudo commands
complete -cf sudo

# History Control
shopt -s histappend
HISTCONTROL="erasedups:ignoreboth"
HISTIGNORE="ls:bg:fg:history:clear:exit"
# HISTSIZE=1000000
# HISTFILESIZE=1000000
# Using `atuin` binary instead for shell history

# Use standard ISO 8601 timestamp
# %F equivalent to %Y-%m-%d
# %T equivalent to %H:%M:%S (24-hours format)
HISTTIMEFORMAT='%F %T '

# PATH
export PATH="/usr/local/bin:$PATH"
export PATH="/var/lib/snapd/snap/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# make `less` more friendly for non-text input files,
# see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm-color | *-256color) color_prompt=yes ;;
esac

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

# Aliases
if [ -f ~/.bash_aliases ]; then
  source "$HOME/.bash_aliases"
fi

# remap caps lock to esc
if [ -f /usr/bin/setxkbmap ]; then
  setxkbmap -option caps:escape
fi

# SSH i3 Rename Window Alias
ssh() {
  if [ "$(ps -p "$(ps -p $$ -o ppid=)" -o comm=)" = "tmux: server" ]; then
    tmux rename-window "$(echo "$@" | rev | cut -d ' ' -f1 | rev | cut -d . -f 1)"
    command ssh "$@"
    tmux set-window-option automatic-rename "on" 1>/dev/null
  else
    command ssh "$@"
  fi
}

#### APPLICATIONS ####

# Serverless binary
if [ "$(command -v sls)" ]; then
  export PATH="$HOME/.serverless/bin:$PATH"
fi

# FinDomain - DNS Recon
if [ -d /opt/ndomino/EchoPwn ]; then
  alias findomain='/opt/ndomino/EchoPwn/findomain-linux'
fi

# Vagrant
if [ -d /mnt/data/vagrant_home ]; then
  export VAGRANT_HOME="/mnt/data/vagrant_home"
fi

# Wasmer
if [ -d ~/.wasmer ]; then
  export WASMER_DIR="$HOME/.wasmer"

  if [ -s "$WASMER_DIR/wasmer.sh" ]; then
    source "$WASMER_DIR/wasmer.sh"
  fi
fi

# Starship Bash Prompt
# https://starship.rs/
if [ -f /bin/starship ] || [ -f /usr/local/bin/starship ]; then
  eval "$(starship init bash)"
else
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
  eval "$(starship init bash)"
fi

#### LANGUAGES ####
# node
# - install: `curl -fsSL install-node.vercel.app | sh`
export NPM_PACKAGES="${HOME}/.npm-global"
export NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

export NPM_CONFIG_EDITOR="$EDITOR"
export NPM_CONFIG_INIT_AUTHOR_NAME='ndom91'
export NPM_CONFIG_INIT_AUTHOR_EMAIL='yo@ndo.dev'
export NPM_CONFIG_INIT_AUTHOR_URL='https://ndo.dev'
export NPM_CONFIG_INIT_LICENSE='MIT'
export NPM_CONFIG_INIT_VERSION='0.0.1'
export NPM_CONFIG_PROGRESS='true'
export NPM_CONFIG_SAVE='true'

# PNPM
export PATH="$HOME/.pnpm-global:$PATH"
export PNPM_HOME="$HOME/.pnpm-global"

# BUN
if [ -f "$HOME/.bun/bin/bun" ]; then
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

# rust
if [ "$(command -v cargo)" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# golang
if [ "$(command -v go)" ]; then
  # export GOROOT=/usr/local/go
  unset GOROOT
  export GOPATH=$HOME/go
  export PATH="$GOPATH/bin:$GOROOT/bin:$PATH"
fi

# ruby
if [ "$(command -v ruby)" ]; then
  [[ -f "$HOME/.rvm/bin" ]] && export PATH="$PATH:$HOME/.rvm/bin"
  # Load RVM into a shell session *as a function*
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
fi

# perl
if [ "$(command -v perl)" ]; then
  PATH="$HOME/perl5/bin${PATH:+:${PATH}}"
  export PATH
  PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
  export PERL5LIB
  PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
  export PERL_LOCAL_LIB_ROOT
  PERL_MB_OPT="--install_base "$HOME/perl5""
  export PERL_MB_OPT
  PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"
  export PERL_MM_OPT
fi

# fnm
if [ "$(command -v fnm)" ]; then
  eval "$(fnm env --use-on-cd --version-file-strategy recursive)"
fi

# AWS
export AWS_DEFAULT_REGION=eu-central-1
export AWS_REGION=eu-central-1

# colorscript
if [ -f "$HOME/.dotfiles/colorscripts/crunchbang-mini.sh" ]; then
  "$HOME/.dotfiles/colorscripts/crunchbang-mini.sh"
fi

# atuin - shell history
if [ "$(command -v atuin)" ]; then
  [[ -f ~/.bash-preexec.sh ]] && source "$HOME/.bash-preexec.sh"
  eval "$(atuin init bash)"
fi
