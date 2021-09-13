#!/bin/bash

artist=`dbus-send \
        --print-reply \
        --dest=org.mpris.MediaPlayer2.spotify \
          /org/mpris/MediaPlayer2 \
          org.freedesktop.DBus.Properties.Get \
          string:'org.mpris.MediaPlayer2.Player' \
          string:'Metadata' \
          | egrep -A 2 "artist" \
          | egrep -v "artist" \
          | egrep -v "array" \
          | cut -b 27- \
          | cut -d '"' -f 1 \
          | egrep -v ^$`

artistLen=${#artist}
lim=30
if [ "$artistLen" -gt "$lim" ]; then
    rem=$(($artistLen-$lim))
    artist=${artist::-$rem}"..."
fi

echo $artist
