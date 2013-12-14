#
# ~/.zlogin
#

if [ -n "$HOST" -a -f "$HOME/.zlogin.$HOST" ]; then
    source "$HOME/.zlogin.$HOST"
fi
