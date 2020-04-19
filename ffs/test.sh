#!/bin/bash
targets=($(hcitool con | grep -oE "([[:alnum:]]+:){5}[[:alnum:]]+"))
first=true

for i in "${targets[@]}"
do
    # pwr=`hcitool tpl $i | grep -oE "[[:digit:]]+"`
    name=`hcitool name $i`
    # if [[ "${name}" ]]; then
    # name=`hcitool name $i`
    if [ -z "$name" ]; then
        if [ $i == "FE:C0:47:E8:C1:7D" ]; then
            name="MX Master 2"
        else
            name=$i
        fi
    fi

    if [ $first = true ]; then
        first=false
        echo "Bluetooth: $name"
    else
        echo 4
        echo "           $name"
    fi
done
