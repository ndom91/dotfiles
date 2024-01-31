# shellcheck shell=bash
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
#

# Alias Functions
if [ -f ~/.bash_aliases_functions ]; then
  . ~/.bash_aliases_functions
fi

#### DOTFILES GIT BARE REPO ####
alias pdot='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
alias dot='/usr/bin/git --git-dir=$HOME/public-dotfiles/ --work-tree=$HOME'
alias lazydot='/bin/lazygit --git-dir=$HOME/public-dotfiles/ --work-tree=$HOME'

#### APPLICATIONS ####
if [ -f /bin/eza ]; then
  alias ll='eza --icons -l -a --group-directories-first --time-style long-iso --classify --group'
  alias llg='eza --icons --git-repos --git -l -a --group-directories-first --time-style long-iso --classify --group'
  alias ls='eza --icons --group-directories-first --classify'
  alias tree='eza --long --tree --time-style long-iso --icons --group'
else
  alias ll='ls -hal'
  alias lls='ls -hSral'
  alias ls='ls -h'
  alias li='ls -laXh --group-directories-first --color=auto'
fi

alias dfh='df -h -x overlay -x tmpfs'
alias hn='hostname'
alias topfolders='sudo du -hs * | sort -rh | head -5'
alias topfiles='sudo find -type f -exec du -Sh {} + | sort -rh | head -n 5'
alias emptytrash='rm -rf ~/.local/share/Trash/*'
alias tb='nc termbin.com 9999'
alias hibernate="echo disk > sudo /sys/power/state"
alias nightmode='echo 900 > /sys/class/backlight/intel_backlight/brightness > /dev/null & sct 3100 > /dev/null'
alias daymode='echo 3000 > /sys/class/backlight/intel_backlight/brightness > /dev/null & sct 4500 > /dev/null'

[[ "$(command -v rg)" ]] && alias rg='rg -S --iglob !.bun --iglob !node_modules --iglob !*.bzr --iglob !*.git --iglob !*.hg --iglob !*.svn --iglob !*.idea --iglob !*.tox'
[[ "$(command -v nvim)" ]] && alias vim='nvim'
[[ "$(command -v vifm)" ]] && alias vifm='~/.config/vifm/scripts/vifmrun'
[[ "$(command -v haste)" ]] && alias haste='HASTE_SERVER=https://paste.ndo.dev haste'
[[ "$(command -v paru)" ]] && alias yay='paru'
[[ "$(command -v xclip)" ]] && alias xc='xclip -selection c'
[[ "$(command -v wl-copy)" ]] && alias xc='wl-copy'
[[ "$(command -v tailscale)" ]] && alias ts='tailscale'
[[ "$(command -v docker)" ]] && alias dockeriprune='sudo docker rmi $(sudo docker images --filter "dangling=true" -q --no-trunc)'
[[ "$(command -v solaar)" ]] && alias solaar="sudo /usr/bin/solaar"
[[ "$(command -v lazygit)" ]] && alias lg="lazygit"
[[ "$(command -v lazydocker)" ]] && alias ld="lazydocker"
[[ "$(command -v diskonaut)" ]] && alias diskgraph="diskonaut"
[[ "$(command -v dua)" ]] && alias disklist="dua i"
[[ "$(command -v nerdctl)" ]] && alias nerdctl="nerdctl --address /var/run/docker/containerd/containerd.sock"
[[ "$(command -v obsidian)" ]] && alias obsidian="OBSIDIAN_USE_WAYLAND=1 obsidian -enable-features=UseOzonePlatform -ozone-platform=wayland"

# Wayland Electron Apps
# alias 1password='1password --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto --socket=wayland'

#### GIT ####
if [ "$(command -v git)" ]; then
  alias cob='git checkout $(git branch -a | cut -c 3- | sed "s/remotes\/origin\///g" | gum filter --reverse)'
  alias gs='git status'
  alias gss='git status --short'
  alias gd='git diff'
  alias gp='git pull'
  alias gl='git log --oneline --color | emojify | most'
  alias gm='gitmoji -c'
  alias g='git'
  alias gpb='git push origin `git rev-parse --abbrev-ref HEAD`'
  alias gpl='git pull origin `git rev-parse --abbrev-ref HEAD`'
  alias glb='git checkout $(git for-each-ref --sort=-committerdate --count=20 --format="%(refname:short)" refs/heads/ | gum filter --reverse)'
  alias ds='dot status'
  alias ddi='dot diff'
  alias gitroot='cd "$(git rev-parse --show-toplevel)"'
fi

#### TYPOS ####
alias suod='sudo'
alias sduo='sudo'
alias udso='sudo'
alias suod='sudo'
alias sodu='sudo'

alias whcih='which'
alias whchi='which'
alias wchih='which'

alias cd.='cd ..'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias .4='cd ../../../../../'
alias .5='cd ../../../../../../'

alias jctl='journalctl -p 3 -xb'
alias gam="/home/ndo/bin/gamadv-xtd3/gam"

# alias npm="npx socket-npm"
# alias npx="npx socket-npx"

alias na='cd /opt/nextauthjs/next-auth/'
alias naa='cd /opt/nextauthjs/next-auth/'
alias nad='cd /opt/nextauthjs/nextra-docs/'

alias cast='mkchromecast -n "Kitchen speaker" --notifications'

alias pvetunnel='ssh -L 8005:192.168.1.201:8006 nt-hulk'
alias grafanatunnel='ssh -L 3000:10.0.1.60:3000 ndo-pve'
alias win10tunnel='ssh -L 3389:192.168.11.169:3389 nt-hulk'
alias casapitunnel='ssh -L 8123:127.0.0.1:8123 tunnelpi'
alias mirrorReboot="ssh mmpi 'pm2 restart 0'"
