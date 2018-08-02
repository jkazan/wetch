# wetch - conky and lua for system monitoring
[![N|Solid](https://i.imgur.com/OQfwIqf.jpg)](https://i.imgur.com/OQfwIqf.jpg)
![N|Solid](https://img.shields.io/badge/Debian-Tested-green.svg?longCache=true&style=popout-square)
### The following is being monitored: 

- Current weather conditions including temperature, ReelFeel,
  couldiness, wind speed, wind direction, humidity and weather quality
  algorithm
- 12 hour weather forecast with icons located by the corresponding
  time on the clock
- Time, day, date
- Wifi signal, wi-fi network
- RAM usage
- CPU usage
- Battery level along with estimated time remaining until empty, or if
  connected, until full
- Slack unread messages. This is being tracked even if user is not logged in
- Spotify information on currently playing artist and title


### Installation
```sh
$ cd ~/
$ sudo apt-get install conky-all
$ git clone https://github.org/jkazan/wetch
$ mkdir .fonts
$ mv wetch/PoiretOne-Regular.ttf .fonts/
$ fc-cache -fv
```

### Configuration
Create `wetch.config` and write it as the example in `wetch.config.example`

If you do not use Slack or Spotify, or if you do not which to use
accuweather information: Open `luascript.lua` and remove, or comment
out, `drawSpotify()` and/or `slack()` and/or `drawWeather()` in the
`conky_main()` function. Note that comment syntax in lua is `--`

### Run
```sh
$ bash ~/conky/wetch.sh
```

# Important
`wetch.sh` is using four different accuweather API keys in order to
increase number of calls allowed per day. Alter the code as you wish,
per the MIT license.
