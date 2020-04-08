#!/bin/bash

id_current=$(cat ~/.cache/wetch/spotify_cover_id)

id_new=`dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | grep spotify:track | cut -d ":" -f3 | cut -d '"' -f1 | sed -n '1p'`

cover=""
imgurl=""
if [ "$id_new" != "$id_current" ]; then
	cover=`ls ~/.cache/wetch/ | grep $id_new`

	if [ "$cover" == "" ]; then
	    imgurl=`dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | egrep -A 1 "artUrl" | egrep -v "artUrl"| cut -b 44- | cut -d '"' -f 1`

        wget -q -O ~/.cache/wetch/current.jpg $imgurl &> /dev/null
        find ~/.cache/wetch/ -name "current.jpg" -exec mogrify -format png {} \;
	    # rm wget-log #wget-logs are accumulated otherwise
	    # cover=`ls ~/.cache/wetch | grep $id_new`
	fi

	# if [ "$cover" != "" ]; then
	# 	cp ~/.cache/wetch/$cover ~/.cache/wetch/current.jpg
	# else
	# 	cp ~/.cache/wetch/empty.jpg ~/.cache/wetch/current.jpg
	# fi
	echo $id_new > ~/.cache/wetch/spotify_cover_id
fi


wget -q -O ~/test.jpg `dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | egrep -A 1 "artUrl" | egrep -v "artUrl"| cut -b 44- | cut -d '"' -f 1` &> /dev/null
