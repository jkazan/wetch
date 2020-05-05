#!/bin/bash
targets=($(hcitool con | grep -oE "([[:alnum:]]+:){5}[[:alnum:]]+"))
first=true

for i in "${targets[@]}"
do
    name=`hcitool name $i`
    if [ -z "$name" ]; then
        if [ $i == "FE:C0:47:E8:C1:7D" ]; then
            name="MX Master 2"
	elif [ $i == "2C:41:A1:52:B9:27" ]; then
            name="Bose Free Soundsport"
        else
            name=$i
        fi
    fi

    if [ $first = true ]; then
        first=false
        echo "Bluetooth: $name"
    else
        echo "           $name"
    fi
done
