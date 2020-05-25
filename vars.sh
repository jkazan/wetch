networks=$(ifconfig | grep -Eo "^(e|w)[[:alnum:]]+")
export WETCH_NETWORKS=$networks

# for i in "${!array[@]}"; do
#     echo "$i ${array[i]}"
# done
