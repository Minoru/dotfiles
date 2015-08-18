#
# ~/.zshenv
#

export PATH=$HOME/.local/bin:$HOME/.bin:$HOME/.scripts:$PATH

# Simply dispatch to the appropriate file
if [ -n "$HOST" -a -f "$HOME/.zshenv.$HOST" ]; then
    source "$HOME/.zshenv.$HOST"
fi
