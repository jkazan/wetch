#!/bin/bash
connections=($(hcitool con | grep -oE "(\w+:){5}\w+"))
first=true
device=($(hcitool dev | grep -o -E '(\w+:){5}\w+'))
for i in "${connections[@]}"
do
    name=$(sudo cat /var/lib/bluetooth/${device}/${i}/info \
               | grep Name= \
               | awk -F'=' '{print $2}')

    if [ $first = true ]; then
        first=false
        echo "Bluetooth: $name"
    else
        echo "           $name"
    fi
done
