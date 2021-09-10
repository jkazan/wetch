#!/bin/bash

echo "$(xrandr | grep -Eo 'primary \w+' | grep -Eo '[[:digit:]]+$')" > ~/wetch/.height
repo_path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
echo "$USER" > $repo_path/.user

conky -dq -c ~/wetch/time_rc
conky -dq -c ~/wetch/misc_rc
conky -dq -c ~/wetch/spotify_rc
conky -dq -c ~/wetch/load_rc
conky -dq -c ~/wetch/network_rc
