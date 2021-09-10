#!/bin/bash

source ~/wetch/wetch.config

# relative path
path="`dirname \"$0\"`"

# absolutized and normalized path
path="`( cd \"$path\" && pwd )`"

# Check if cache file exists
if [ ! -f ~/.cache/wetch/slack.unread ]; then
    echo 0 > ~/.cache/wetch/slack.unread
fi

unrd_count=0

# Check unread message count in all specified channels
for i in ${WETCH_CH[@]} ; do
    chan_url='https://slack.com/api/channels.info?token='$WETCH_TK'&channel='$i
    (( unrd_count+=$(curl -s $chan_url | jq '.channel.unread_count_display') ))
done

# Check unread message count in all specified private conversations
for i in ${WETCH_CO[@]} ; do
    con_url='https://slack.com/api/conversations.info?token='$WETCH_TK'&channel='$i
    (( unrd_count+=$(curl -s $con_url | jq '.channel.unread_count_display') ))
done

# Send notification if there is a new message
if [[ $unrd_count -gt $(head -n 1 ~/.cache/wetch/slack.unread) ]] ; then
    if [[ $unrd_count == 1 ]] ; then
        notify-send -i ~/wetch/slack-web.png wetch "$unrd_count unread message"
    else
        notify-send -i ~/wetch/slack-web.png wetch "$unrd_count unread messages"
    fi
fi

# Update cache
echo $unrd_count > ~/.cache/wetch/slack.unread

echo $unrd_count


# curl -X POST -H 'Content-type: application/json' --data \
#      '{"text":"first line!\nsecond line"}' \
#      https://hooks.slack.com/services/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

# GET /api/channels.history?token=xoxp-84764440833-338222342822-371761006930-763f2b10ff6c798d49821f3523b0ef66&channel=DCW2BUY65&latest=1476909142.000007&inclusive=true&count=1
