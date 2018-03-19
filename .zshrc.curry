export EDITOR=$HOME/.nix-profile/bin/vim
# Via http://iamnearlythere.com/man-pages-in-color-and-links/
export MANPAGER="nvim -c 'set ft=man' -"

[[ -n ${IN_NIX_SHELL} ]] && PROMPT="%{$fg[yellow]%}nix-shell %# %{$reset_color%}"
