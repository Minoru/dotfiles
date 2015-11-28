#!/bin/sh

xrdb -merge $HOME/.Xdefaults
xrdb -merge $HOME/.Xresources

# start redshift
.scripts/start-redshift &

# this beast needs dbus for some reason...
! pgrep -u $USER parcimonie && ionice -c 2 -n 7 nice -n 20 parcimonie \
>$HOME/.parcimonie.log 2>&1 &

# setting default cursor to left pointer
xsetroot -cursor_name left_ptr

xbindkeys &

xset s off

# setting up the background
feh --bg-scale '/home/minoru/pictures/wallpapers/current.png' &

# start urxvt terminal daemon
urxvtd --quiet --opendisplay --fork

# remap the keyboard the way I like it
setxkbmap -layout 'us' -option -option 'compose:lwin' \
-option 'terminate:ctrl_alt_bksp' -option 'ctrl:swapcaps'

xrdb -merge $HOME/.Xdefaults
xrdb -merge $HOME/.Xresources

if [ -n "$HOST" -a -f "$HOME/.xsession.$HOST" ]; then
    echo "Starting $HOME/.xsession.$HOST"
    exec sh "$HOME/.xsession.$HOST"
fi
