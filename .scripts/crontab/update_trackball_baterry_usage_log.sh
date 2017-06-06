#!/bin/sh

(
    echo -n "`date +\%s` "
    sudo $HOME/.nix-profile/bin/solaar-cli show --verbose 1 | grep 'Battery' | sed -r 's#^[^[:digit:]]*([[:digit:]]+\%).*$#\1#'
) >> /home/minoru/misc/trackball_battery_usage.log
