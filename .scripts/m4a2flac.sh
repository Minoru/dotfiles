#!/bin/sh

# Converts m4a files to flac, preserving tags and adding ReplayGain

for name in "$@"; do
    echo -n "$name : "

    echo -n "tags... "
    album="`mediainfo \"$name\" | egrep 'Album +:' | head -1 | sed -r 's/^Album\s+: //'`"
    title="`mediainfo \"$name\" | egrep 'Track name +:' | head -1 | sed -r 's/^Track name\s+: //'`"
    tracknumber="`mediainfo \"$name\" | egrep 'Track name/Position +:' | head -1 | sed -r 's#^Track name/Position\s+: ##'`"
    total="`mediainfo \"$name\" | egrep 'Track name/Total +:' | head -1 | sed -r 's#^Track name/Total\s+: ##'`"
    artist="`mediainfo \"$name\" | egrep 'Performer +:' | head -1 | sed -r 's#^Performer\s+: ##'`"
    performer="$artist"
    genre="`mediainfo \"$name\" | egrep 'Genre +:' | head -1 | sed -r 's#^Genre\s+: ##'`"
    date="`mediainfo \"$name\" | egrep 'Recorded date +:' | head -1 | sed -r 's#^Recorded date\s+: ##'`"
    # put tags into temporary file
    tmp="`mktemp`"
    echo "ALBUM=$album" >"$tmp"
    echo "TITLE=$title" >>"$tmp"
    echo "TRACKNUMBER=$tracknumber" >>"$tmp"
    echo "TOTAL=$total" >> "$tmp"
    echo "ARTIST=$artist" >> "$tmp"
    echo "PERFORMER=$performer" >> "$tmp"
    echo "GENRE=$genre" >> "$tmp"
    echo "DATE=$date" >> "$tmp"

    echo -n "wav... "
    wav="`basename \"$name\" '.m4a'`.wav"
    nice ffmpeg -loglevel quiet -y -i "$name" -vn -acodec pcm_s16le -f wav -threads auto "$wav"
    echo -n "flac... "
    nice flac -8 --replay-gain -s "$wav"
    rm -f "$wav"

    echo -n "metaflac... "
    flac="`basename \"$name\" '.m4a'`.flac"
    nice metaflac --import-tags-from="$tmp" --add-replay-gain "$flac"

    rm -f "$tmp"
    echo
done

