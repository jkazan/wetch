#!/bin/bash

metadata=`dbus-send \
          --print-reply \
          --session \
          --dest=org.mpris.MediaPlayer2.spotify \
            /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get \
            string:'org.mpris.MediaPlayer2.Player' \
            string:'Metadata'`

url_current=$(cat ~/.cache/wetch/spotify_cover_url)
url_new=`echo $metadata | grep -Po '(?<=artUrl\" variant string \")[^\"]+(?=\")'`
if [ "$url_new" != "$url_current" ]; then
    wget ~/.cache/wetch/current.jpeg ${url_new} -q -o /dev/null -O &> /dev/null
    ffmpeg \
        -loglevel error \
        -y -i ~/.cache/wetch/current.jpeg \
        -preset ultrafast ~/.cache/wetch/current.png
    echo $url_new > ~/.cache/wetch/spotify_cover_url
fi

artist_current=$(cat ~/.cache/wetch/spotify_artist)
artist_new=`echo $metadata | grep -Po '(?<=artist\" variant array \[ string \")[^\"]+(?=\")'`
if [ "$artist_new" != "$artist_current" ]; then
    echo $artist_new > ~/.cache/wetch/spotify_artist
fi

title_current=$(cat ~/.cache/wetch/spotify_title)
title_new=`echo $metadata | grep -Po '(?<=title\" variant string \")[^\"]+(?=\")'`
if [ "$title_new" != "$title_current" ]; then
    echo $title_new > ~/.cache/wetch/spotify_title
fi

