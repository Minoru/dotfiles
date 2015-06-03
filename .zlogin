#
# ~/.zlogin
#

# in case it's not exported yet
export HOST="$HOST"

if [ -n "$HOST" -a -f "$HOME/.zlogin.$HOST" ]; then
    source "$HOME/.zlogin.$HOST"
fi
