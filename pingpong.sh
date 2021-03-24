#!/bin/bash

pp=`curl -s http://10.96.59.43:3030/blob | jq '.message' | tr -d '"'`
# SUB="is occupied"
note=$(</home/johannek/.cache/wetch/pingpong)
# now=$(date +%H:%M)
# start="13:00"
# end="15:30"
if [[ "$pp" == *"is occupied"* ]]; then
    echo 0 > /home/johannek/.cache/wetch/pingpong
    echo "Currently occupied"
elif [[ "$pp" == *"been occupied for"* ]]; then
    echo 0 > /home/johannek/.cache/wetch/pingpong
    echo ${pp//minutes/min} | cut -c 30-
else
    echo ${pp//minutes/min} | cut -c 30-
    if [[ $note == 0 ]]; then
        notify-send "Ping Pong" "Table is now available" -i ~/wetch/pingpong.png
        echo 1 > /home/johannek/.cache/wetch/pingpong
    fi
fi

# if [[ "$pp" == *"$SUB"* ]]; then
#     echo "Currently occupied"
# else
#     echo ${pp//minutes/min} | cut -c 30-
#     # if [[ "$now" > "$start" ]] && [[ "$now" < "$end" ]] && [[ $note == 0 ]]; then
#     if [[ $note == 0 ]]; then
#         notify-send "Ping Pong" "Table is now available" -i ~/wetch/pingpong.png
#         echo 1 > /home/johannek/.cache/wetch/pingpong
#     fi
# fi

# if [[ "$now" < "$start" ]] || [[ "$now" > "$end" ]]; then
#     echo 0 > /home/johannek/.cache/wetch/pingpong
# fi
