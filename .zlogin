#
# ~/.zlogin
#

# in case it wasn't exported yet...
export HOST
export PATH=$HOME/.local/bin:$HOME/.bin:$HOME/.scripts:$PATH

if [ -n "$HOST" -a -f "$HOME/.zlogin.$HOST" ]; then
    source "$HOME/.zlogin.$HOST"
fi
