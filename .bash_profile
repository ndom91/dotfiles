export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export GPG_TTY=$(tty)

unset DOCKER_TLS_VERIFY
unset DOCKER_HOST

source ~/.bashrc


if [ -e /home/ndo/.nix-profile/etc/profile.d/nix.sh ]; then . /home/ndo/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
