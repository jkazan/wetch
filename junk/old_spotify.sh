
# #!/bin/bash

# metadata=`dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'`

# artist=$(echo "${metadata}" | egrep -A 2 "artist"|egrep -v "artist"|egrep -v "array"|cut -b 27-|cut -d '"' -f 1|egrep -v ^$)
# title=$(echo "${metadata}" | awk '/title/{getline; print}' | grep -o "\".*\"" | sed 's/"//g')
# length=$(echo "${metadata}" | awk '/length/{getline; print}' | grep -Eo "[[:digit:]]{3,}")




# mkdir -p ~/.cache/wetch/
# touch ~/.cache/wetch/spotify_cover_id
# id_current=$(cat ~/.cache/wetch/spotify_cover_id)

# id_new=$(echo "${metadata}" | grep spotify:track | cut -d ":" -f3 | cut -d '"' -f1 | sed -n '1p')
# cover=""
# imgurl=""
# if [ "$id_new" != "$id_current" ]; then
# 	cover=`ls ~/.cache/wetch/ | grep $id_new`

# 	if [ "$cover" == "" ]; then
# 	    imid=$(echo "${metadata}" | grep -Eo "[[:alnum:]]{30,}")
            
#         imgurl="https://d3rt1990lpmkn.cloudfront.net/640/${imgid}"

#         wget ~/.cache/wetch/current.jpeg $imgurl -q -o /dev/null -O &> /dev/null
#         find ~/.cache/wetch/ -name "current.jpeg" -exec mogrify -format png {} \;

# 	fi

# 	echo $id_new > ~/.cache/wetch/spotify_cover_id
# fi


# echo "artist: $artist"
# echo "title: $title"
# echo "length: $length"

# # bash spotify.sh | grep -E "title" | sed 's/title: //g'
# # bash spotify.sh | grep -E "artist" | sed 's/artisttitle: //g'
# # bash spotify.sh | grep -E "length" | sed 's/length: //g'
