#!/bin/sh

# start redshift
.scripts/start-redshift &

# this beast needs dbus for some reason...
! pgrep -u $USER parcimonie && ionice -c 2 -n 7 nice -n 20 parcimonie >$HOME/.parcimonie.log 2>&1 &

# setting default cursor to left pointer
xsetroot -cursor_name left_ptr

xbindkeys &

xset s off

# setting up the background
feh --bg-scale '/home/minoru/pictures/wallpapers/current.png' &

# disabling touchpad on typing
syndaemon -i 1 -K -d -p $HOME/.syndaemon.pid
# enable tapping
synclient TapButton1=1 TapButton2=2 TapButton3=3

# start urxvt terminal daemon
urxvtd --quiet --opendisplay --fork

if [ -n "$HOST" -a -f "$HOME/.xsession.$HOST" ]; then
    echo "Starting $HOME/.xsession.$HOST"
    exec sh "$HOME/.xsession.$HOST"
fi
