id_new=`dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | grep spotify:track | cut -d ":" -f3 | cut -d '"' -f1 | sed -n '1p'`

imgid=`dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | grep -Eo "[[:alnum:]]{30,}"` #| egrep -A 1 "artUrl" | egrep -v "artUrl"| cut -b 44- | cut -d '"' -f 1`
imgurl="https://d3rt1990lpmkn.cloudfront.net/640/${imgid}"
echo ${imgurl}
# wget ${imgurl} -O ./test.jpg

 # https://d3rt1990lpmkn.cloudfront.net/640/f15552e72e1fcf02484d94553a7e7cd98049361a
