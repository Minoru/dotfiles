export EDITOR=/run/current-system/sw/bin/vim

[[ -n ${IN_NIX_SHELL} ]] && PROMPT="%{$fg[yellow]%}nix-shell %# %{$reset_color%}"
