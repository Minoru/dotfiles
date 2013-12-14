#!/bin/sh

# Purge vim's undodir (:help 'undodir', vim >= 7.3) from undofiles that does
# not have corresponding files in the filesystem anymore
#
# Intended to be called from crontab(1) job like that:
#
# # Purge undodir every week at 8:05AM
# 5 8 * * 1 /home/minoru/.scripts/crontab/purge_vim_undodir /home/minoru/.vim/undofiles
#
# Do not forget about the newline at the end of crontab file!

undodir="$1"

if [ -z "$undodir" ]
then
    echo "Path to undodir not specified." >&2
    exit 1
fi

if [ ! -d "$undodir" ]
then
    echo "Undodir ($undodir) does not exist (or isn't a directory)." >&2
    exit 2
fi

cd "$undodir"

for undofile in *
do
    filepath=`echo -n "$undofile" | sed 's#%#/#g'`
    if [ ! -e "$filepath" ]
    then 
        rm -f "$undofile"
    fi
done

cd - >/dev/null

