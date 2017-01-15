export EDITOR=/nix/var/nix/profiles/default/bin/vim

[[ -n ${IN_NIX_SHELL} ]] && PROMPT="%{$fg[yellow]%}nix-shell %# %{$reset_color%}"
