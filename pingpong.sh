#!/bin/bash

pp=`curl -s http://10.96.59.43:3030/blob | jq '.message' | tr -d '"'`
SUB="is occupied"
if [[ "$pp" == *"$SUB"* ]]; then
    echo "Currently occupied"
else
    echo ${pp//minutes/min} | cut -c 30-
fi
