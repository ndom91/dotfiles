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

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	alias grep='grep --color=auto --exclude-dir={node_modules,.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
	alias fgrep='fgrep --color=auto --exclude-dir={node_modules,.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
	alias egrep='egrep --color=auto --exclude-dir={node_modules,.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
fi

#### DOTFILES GIT BARE REPO ####
alias pdot='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
alias dot='/usr/bin/git --git-dir=$HOME/public-dotfiles/ --work-tree=$HOME'
alias lazydot='/bin/lazygit --git-dir=$HOME/public-dotfiles/ --work-tree=$HOME'

#### APPLICATIONS ####
if [ -f /usr/bin/exa ]; then
	alias ll='exa --icons -l -a --group-directories-first --time-style long-iso --classify --group'
	alias ls='exa --icons --group-directories-first --classify'
	alias tree='exa --long --tree --time-style long-iso --icons --group'
else
	alias ll='ls -hal'
	alias lls='ls -hSral'
	alias ls='ls -h'
	alias li='ls -laXh --group-directories-first --color=auto'
fi

# Built-in Applications
alias greg='greg --highlight'
alias oni2='/opt/Onivim2.AppDir/usr/bin/Oni2'
alias dfh='df -h -x overlay -x tmpfs'
alias hn='hostname'
alias topfolders='sudo du -hs * | sort -rh | head -5'
alias topfiles='sudo find -type f -exec du -Sh {} + | sort -rh | head -n 5'
alias emptytrash='rm -rf ~/.local/share/Trash/*'
alias tb='nc termbin.com 9999'
alias hibernate="echo disk > sudo /sys/power/state"
alias nightmode='echo 900 > /sys/class/backlight/intel_backlight/brightness > /dev/null & sct 3100 > /dev/null'
alias daymode='echo 3000 > /sys/class/backlight/intel_backlight/brightness > /dev/null & sct 4500 > /dev/null'
alias activeSysd='for i in $(cd /etc/systemd/system/multi-user.target.wants && ls *.service); do script -q -c "systemctl status -n 0 --no-pager $i" |head -n 1; script -q -c "systemctl status -n 0 --no-pager $i" |grep --color=never "Active: "; done;'

# Custom Applications
[[ "$(command -v rg)" ]] && alias rg='rg -S --iglob !.bun --iglob !node_modules --iglob !*.bzr --iglob !*.git --iglob !*.hg --iglob !*.svn --iglob !*.idea --iglob !*.tox'
[[ "$(command -v nvim)" ]] && alias vim='nvim'
[[ "$(command -v vifm)" ]] && alias vifm='~/.config/vifm/scripts/vifmrun'
[[ "$(command -v haste)" ]] && alias haste='HASTE_SERVER=https://paste.ndo.dev haste'
[[ "$(command -v paru)" ]] && alias yay='paru'
[[ "$(command -v xclip)" ]] && alias xc='xclip -selection c'
[[ "$(command -v wl-copy)" ]] && alias xc='wl-copy'
[[ "$(command -v tailscale)" ]] && alias ts='tailscale'
[[ "$(command -v rtm)" ]] && alias rtmrl='rtm ls priority:1 OR priority:2 OR priority:3 OR list:PERSONAL OR dueBefore:tomorrow OR tag:todo'
[[ "$(command -v bat)" ]] && alias cat='bat --theme=Dracula '
[[ "$(command -v docker)" ]] && alias dockeriprune='sudo docker rmi $(sudo docker images --filter "dangling=true" -q --no-trunc)'
[[ "$(command -v solaar)" ]] && alias solaar="sudo /usr/bin/solaar"
[[ "$(command -v lazygit)" ]] && alias lg="lazygit"
[[ "$(command -v lazydocker)" ]] && alias ld="lazydocker"
[[ "$(command -v diskonaut)" ]] && alias diskgraph="diskonaut"
[[ "$(command -v dua)" ]] && alias disklist="dua i"
[[ "$(command -v nerdctl)" ]] && alias nerdctl="nerdctl --address /var/run/docker/containerd/containerd.sock"
# [[ "$(command -v fd)" ]] && alias find='fd'
# [[ "$(command -v pnpm)" ]] && alias npm="pnpm"

alias brave="brave --silent-debugger-extension-api"

# Git
if [ "$(command -v git)" ]; then
	alias cob='git checkout $(git branch -a | cut -c 3- | pick)'
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

# TYPO FIXES
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

### PID1
alias jctl='journalctl -p 3 -xb'

### GAM
alias gam="/home/ndo/bin/gamadv-xtd3/gam"

### SOCKET
alias npm="npx socket-npm"
alias npx="npx socket-npx"

### NEXT-AUTH ###
alias na='cd /opt/next-auth/next-auth/'
alias naa='cd /opt/next-auth/next-auth/packages/'
alias nad='cd /opt/next-auth/next-auth/packages/docs'

#### SSH Tunnels ####
alias pvetunnel='ssh -L 8005:192.168.1.201:8006 nt-hulk'
alias grafanatunnel='ssh -L 3000:10.0.1.60:3000 ndo-pve'
alias win10tunnel='ssh -L 3389:192.168.11.169:3389 nt-hulk'
alias casapitunnel='ssh -L 8123:127.0.0.1:8123 tunnelpi'
alias mirrorReboot="ssh mmpi 'pm2 restart 0'"
alias clidle="ssh clidle.ddns.net -p 3000"

# CHECKLY
alias checkly-cli='/opt/checkly/checkly-cli/bin/run'
alias dockermachine='eval $(docker-machine env checkly-pi)'
alias cwa='cd /opt/checkly/checkly-webapp'
alias cbe='cd /opt/checkly/checkly-backend'
alias clr='cd /opt/checkly/checkly-lambda-runners'
alias chq='cd /opt/checkly/checklyhq.com'
