# wetch - conky and lua for system monitoring
[![N|Solid](https://i.imgur.com/OQfwIqf.jpg)](https://i.imgur.com/OQfwIqf.jpg)
![N|Solid](https://img.shields.io/badge/Debian-Tested-green.svg?longCache=true&style=popout-square) ![N|Solid](https://img.shields.io/badge/Ubuntu-Tested-green.svg?longCache=true&style=popout-square) ![N|Solid](https://img.shields.io/badge/License-MIT-blue.svg?longCache=true&style=popout-square)
### The following is being monitored: 

- Current weather conditions including temperature, ReelFeel,
  cloudiness, wind speed, wind direction, humidity and weather quality
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
$ sudo apt-get install conky-all
$ git clone https://github.com/jkazan/wetch
$ cd wetch
$ bash install.sh
```

### Configuration
If you want to use weather and/or Slack features in wetch, add
information in `wetch.config` as per instructions.

### Run
```sh
Usage: wetch [OPTION]
Options:
  -h   show brief help
  -w   run wetch with weather features
  -s   run wetch with Slack features
```

#### Examples
##### Run vanilla
```sh
./wetch
```
##### Run with all features
```sh
./wetch -ws
```

# Important
`wetch` is using four different accuweather API keys in order to
increase number of calls allowed per day. Alter the code as you wish,
per the MIT license.
