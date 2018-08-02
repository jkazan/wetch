#!/bin/bash

battery=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 \
              | grep "percentage:[[:space:]]*[0-9]*%" | grep -o [0-9]*)

if [[ $battery -le 15 ]] ; then
    notify-send -i ~/wetch/batlow.svg wetch "Battery $battery%"
fi
