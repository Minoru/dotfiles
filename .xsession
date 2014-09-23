#!/bin/sh

if [ -n "$HOST" -a -f "$HOME/.xsession.$HOST" ]; then
    echo "Starting $HOME/.xsession.$HOST"
    exec sh "$HOME/.xsession.$HOST"
fi
