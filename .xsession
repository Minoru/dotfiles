#!/bin/sh

if [ -n "$HOST" -a -f "$HOME/.xsesion.$HOST" ]; then
    source "$HOME/.xsession.$HOST"
fi
