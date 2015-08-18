#
# ~/.zlogin
#

# in case it wasn't exported yet...
export HOST
export PATH=$HOME/.local/bin:$HOME/.bin:$HOME/.scripts:$PATH
export PYTHONSTARTUP="$HOME/.pystartup"
export BROWSER='/usr/bin/iceweasel'
export GTK_IM_MODULE="xim"
export MPD_HOST='::1'
export XDG_DATA_HOME="$HOME/.config"
export EDITOR=/usr/bin/vim
# exporting EDITOR=vim makes ZSH switch into Vi mode; I don't like that
bindkey -e

if [ -n "$HOST" -a -f "$HOME/.zlogin.$HOST" ]; then
    source "$HOME/.zlogin.$HOST"
fi
