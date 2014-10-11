#
# ~/.zshenv
#

# Simply dispatch to the appropriate file
if [ -n "$HOST" -a -f "$HOME/.zshenv.$HOST" ]; then
    source "$HOME/.zshenv.$HOST"
fi
