#!/bin/bash
mkdir -p ~/.cache/wetch/
touch ~/.cache/wetch/spotify_cover_id
id_current=$(cat ~/.cache/wetch/spotify_cover_id)

id_new=`dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | grep spotify:track | cut -d ":" -f3 | cut -d '"' -f1 | sed -n '1p'`

echo $id_current
echo $id_new

cover=""
imgurl=""
if [ "$id_new" != "$id_current" ]; then
	cover=`ls ~/.cache/wetch/ | grep $id_new`

	if [ "$cover" == "" ]; then
	    imgid=`dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | grep -Eo "[[:alnum:]]{30,}"`
        imgurl="https://d3rt1990lpmkn.cloudfront.net/640/${imgid}"
        # echo $imgurl
        echo "wget ~/.cache/wetch/current.jpeg $imgurl -q -o /dev/null -O &> /dev/null"
        wget ~/.cache/wetch/current.jpeg $imgurl -q -o /dev/null -O &> /dev/null
        find ~/.cache/wetch/ -name "current.jpeg" -exec mogrify -format png {} \;

	fi

	echo $id_new > ~/.cache/wetch/spotify_cover_id
fi
