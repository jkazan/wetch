#!/bin/bash
#
# This script governs the wetch widget

verify_internet_connection() {
    #######################################
    # Check internet connection
    # Globals:
    #   None
    # Arguments:
    #   None
    # Returns:
    #   None
    #######################################
    local timeout=20
    local tries=0
    while !(ping -c 1 google.com > /dev/null) ; do
        sleep 1
        tries=$((tries+1))
        if [ $tries -ge $timeout ] ; then
            notify-send -i ~/wetch/nointernet.svg wetch "No internet connection"
            tries=0
            sleep 300
            continue
        fi
    done
}

set_api_key() {
    #######################################
    # Choose api key depending on time, 4 keys allows 4 times more calls
    # Globals (sourced):
    #   api_key1, api_key2, api_key3, api_key4
    # Arguments:
    #   None
    # Returns:
    #   None
    #######################################

    api_key=""

    local now=$(date +"%s")

    if (( $now >= $(date --date='Today 00:00' +'%s') )) \
           && (( $now < $(date --date='Today 06:00' +'%s') )) ; then
        api_key=$WETCH_K1
    elif (( $now >= $(date --date='Today 06:00' +'%s') )) \
             && (( $now < $(date --date='Today 12:00' +'%s') )) ; then
        api_key=$WETCH_K2
    elif (( $now >= $(date --date='Today 12:00' +'%s') )) \
             && (( $now < $(date --date='Today 18:00' +'%s') )) ; then
        api_key=$WETCH_K3
    else
        api_key=$WETCH_K4
    fi
}

update_weather() {
    notify-send "UPDATING!"
    #######################################
    # Update accuweather data
    # Globals (sourced):
    #   city_code
    # Arguments:
    #   None
    # Returns:
    #   None
    #######################################

    # Get current weather conditions
    local weather_url="http://dataservice.accuweather.com/currentconditions/v1/"
    weather_url+="${WETCH_CC}?apikey=${api_key}&language=en-us&details=true"
    curl -X GET $weather_url -o ~/.cache/wetch/tempweather.json

    # Get 12 hour weather forecast
    local forec_url="http://dataservice.accuweather.com/forecasts/v1/hourly/"
    forec_url+="12hour/${WETCH_CC}?apikey=${api_key}&details=true&metric=true"
    curl -X GET $forec_url -o ~/.cache/wetch/tempforecast.json

    # If service is unavailable, do not overwrite cached data, instead
    # notify user and keep using old data until service is available
    if cat ~/.cache/wetch/tempweather.json | \
            grep -o "Unauthorized" > /dev/null ||
            cat ~/.cache/wetch/tempforecast.json | \
                grep "Unauthorized" > /dev/null ; then
        local unauthorized_message="API key unauthorized, aborting"
        notify-send wetch "$unauthorized_message"
        pkill conky
        exit
    elif cat ~/.cache/wetch/tempweather.json | \
            grep -o "ServiceUnavailable" > /dev/null ||
            cat ~/.cache/wetch/tempforecast.json | \
                grep "ServiceUnavailable" > /dev/null ; then
        notify-send wetch "Weather Service unavailable, using cached data"
    else
        cp ~/.cache/wetch/tempweather.json ~/.cache/wetch/weather.json
        cp ~/.cache/wetch/tempforecast.json ~/.cache/wetch/forecast.json

        # Copy weather icons to cache
        local accuweather="/home/$USER/wetch/accuweather-icons/"
        local weather="$(jq .[].WeatherIcon ~/.cache/wetch/weather.json).png"
        cp $accuweather$weather ~/.cache/wetch/weather.png
        local forecast=""
        for i in {0..11} ; do
            forecast="$(jq .[$i].WeatherIcon ~/.cache/wetch/forecast.json).png"
            cp $accuweather$forecast ~/.cache/wetch/forecast-"$i".png
        done
    fi

    local now=$(date +"%s")
    echo $now > ~/.cache/wetch/last_weather_update.txt
}

verify_last_update() {
    #######################################
    # Make sure cached data exists
    # Globals:
    #   None
    # Arguments:
    #   None
    # Returns:
    #   None
    #######################################

    # Create last_weather_update.txt if non-existing
    if [ ! -f ~/.cache/wetch/last_weather_update.txt ]; then
        echo 0 > ~/.cache/wetch/last_weather_update.txt
        notify-send -i ~/wetch/nointernet.svg wetch "Loading..."
        update_weather
    fi
}

kill_running() {
    #######################################
    # Kill currently running conky session
    # Globals:
    #   None
    # Arguments:
    #   None
    # Returns:
    #   None
    #######################################

    # If conky is running, kill it and start. Makes it possible to
    # reboot anytime
    if ps cax | grep -o conky > /dev/null ; then
        killall conky
        ps axf \
            | grep wetch.sh \
            | grep -v grep \
            | awk 'FNR == 1 {print "kill -9 " $1}' \
            | sh
    fi
}

is_updated() {
    #######################################
    # Check if weather is recently updated
    # Globals:
    #   None
    # Arguments:
    #   None
    # Returns:
    #   0 if updated
    #######################################

    local last_update=$(head -n 1 ~/.cache/wetch/last_weather_update.txt)
    local now=$(date +"%s")
    local deltaH=$(($now - $now%3600 - $last_update + $last_update%3600))

    # If it is less than 15 minutes since last update and it is not a
    # new full hour, return false
    if (( $now - $last_update < 900 && $deltaH == 0 )) ; then
        return 0
    fi

    return 1
}

restart_conky() {
    #######################################
    # Restart conky sessionn
    # Globals:
    #   None
    # Arguments:
    #   None
    # Returns:
    #   None
    #######################################

    killall conky
    conky -c ~/wetch/.conkyrc
}

main() {
    #######################################
    # Main funciton
    # Globals:
    #   None
    # Arguments:
    #   None
    # Returns:
    #   None
    #######################################

    # Create .cache/wetch dir and cache files if non-existing
    mkdir -p ~/.cache/wetch/

    # Verify connection and update weather data
    verify_internet_connection

    # Give 4 api keys and let function select which one to use
    set_api_key

    # Check when wetch was last updated
    verify_last_update

    # Kill any running session
    kill_running

    # Update weather data
    update_weather

    # Start conky
    conky -c ~/wetch/.conkyrc

    # Update weather every 15 minutes (defined in 'is_udpated')
    while true ; do
        if is_updated ; then
            echo updated
            sleep 5
            continue
        fi
        echo "not updated"
        set_api_key
        update_weather
        restart_conky
    done
}

source ~/wetch/wetch.config
main
