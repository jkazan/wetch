require 'cairo'
require 'imlib2'

-------------------------------------
-- Main function
-------------------------------------
function conky_main()
   if conky_window == nil then
      return
   end
   local cs = cairo_xlib_surface_create(conky_window.display,
                                        conky_window.drawable,
                                        conky_window.visual,
                                        conky_window.width,
                                        conky_window.height)
   cr = cairo_create(cs)

   ww=conky_window.width/2
   wh=conky_window.height/2
   center=250

   drawTimeCircles()
   drawDateTime()
   drawRamCpu()
   drawWifi()
   drawBattery()
   drawSpotify()
   drawWeather()
   slack()


   cairo_destroy(cr)
   cairo_surface_destroy(cs)
   cr=nil
end

-------------------------------------
-- Prints, and draws, time information
-------------------------------------
function drawTimeCircles()
   local monitor_flag=conky_parse("${exec cat ~/.cache/wetch/monitor_flag}")

   if monitor_flag == 'false' then
      do return end
   end

   local H=tonumber(conky_parse("${time %H}"))
   local M=tonumber(conky_parse("${time %M}"))
   local S=tonumber(conky_parse("${time %S}"))
   if H > 11 then
      H = H-12
   end
   local hourMeter=H+M/60
   local minuteMeter=M

   circleFill(center, wh, 65, 6, 0, 360, "12", 12, 1, 1, 1, 0.2)
   circleFill(center, wh, 65, 7, 0, 360, hourMeter, 12, 1, 1, 1, 0.4)

   circleFill(center, wh, 76, 4, 0, 360, "60", 60, 1, 1, 1, 0.2)
   circleFill(center, wh, 76, 5, 0, 360, minuteMeter, 60, 1, 1, 1, 0.6)

   local hourPointer=hourMeter/12*360*math.pi/180-math.pi/2
   jline(center+0*math.cos(hourPointer),
         wh+0*math.sin(hourPointer),
         center+50*math.cos(hourPointer),
         wh+50*math.sin(hourPointer),
         7,1,1,1,0.2)

   local minutePointer=minuteMeter/60*360*math.pi/180-math.pi/2
   jline(center+0*math.cos(minutePointer),
         wh+0*math.sin(minutePointer),
         center+55*math.cos(minutePointer),
         wh+55*math.sin(minutePointer),
         5,1,1,1,0.2)

   jline(center+200, wh, center+900, wh, 3, 1,1,1,0.8)
end

function drawDateTime()
   jprint(conky_parse("${time %H}:${time %M}"), center+920, wh+70, 200,
          1, 1, 1, 0.8, CAIRO_FONT_WEIGHT_NORMAL)
   jprint(conky_parse("${execi 300 LANG='' LC_TIME='' date +'%A'}"),
          center+920, wh-100, 80, 1, 1, 1, 0.8, CAIRO_FONT_WEIGHT_NORMAL)
   jprint(conky_parse("${execi 300 LANG='' LC_TIME='' date +'%B %d'}"),
          center+920, wh+160, 80, 1, 1, 1, 0.8, CAIRO_FONT_WEIGHT_NORMAL)
end

function drawWifi()
   local monitor_flag=conky_parse("${exec cat ~/.cache/wetch/monitor_flag}")

   if monitor_flag == 'false' then
      do return end
   end

   local wireless=conky_parse("${exec /sbin/ifconfig | egrep -o '^w[^:]+'}")
   local link_qual="${wireless_link_qual " .. wireless .. "}"

   local essid=conky_parse("${exec iwconfig 2>/dev/null " ..
                              "| grep ESSID | cut -d: -f2 | tr -d '\"'}")

   local isConnected=tonumber(conky_parse("${if_existing /proc/net/route " ..
                                          wireless .. "}1${else}0${endif}"))

   if isConnected == 0 or wireless == "" then
      circleFill(center, wh, 130, 6, 0, 80, "100", 100, 1, 0, 0, 0.2)
   else
      circleFill(center, wh, 130, 6, 0, 80, "100", 100, 1, 1, 1, 0.2)
      circleFill(center, wh, 130, 6, 0, 80, link_qual, 100, 1, 1, 1, 0.4)
   end

   jprint("wi-fi",
          center-40,
          wh-125,
          16,1,1,1,1,
          CAIRO_FONT_WEIGHT_NORMAL)

   jprint(conky_parse(essid),
          center-40,
          wh-140,
          14,1,1,1,1,
          CAIRO_FONT_WEIGHT_NORMAL)
end

-------------------------------------
-- Prints, and draws, ram information
-------------------------------------
function drawRamCpu()
   local monitor_flag=conky_parse("${exec cat ~/.cache/wetch/monitor_flag}")

   if monitor_flag == 'false' then
      do return end
   end

   circleFill(center, wh, 130, 6, 120, 200, "100", 100, 1, 1, 1, 0.2)
   circleFill(center, wh, 130, 6, 120, 200, "${cpu}", 100, 1, 1, 1, 0.5)
   jprint("cpu", center+105, wh+55, 16, 1, 1, 1, 1, CAIRO_FONT_WEIGHT_NORMAL)


   circleFill(center, wh, 95, 12, 0, 80, "100", 100, 1, 1, 1, 0.2)
   circleFill(center, wh, 95, 12, 0, 80, "${memperc}", 100, 1, 1, 1, 0.5)
   jprint("ram", center-40, wh-90, 16, 1, 1, 1, 1, CAIRO_FONT_WEIGHT_NORMAL)

   local start=100
   local length=26
   local stop=21

   for i=0, 3, 1
   do
      cpuinner="${cpu cpu" .. i+1 .. "}"
      circleFill(center, wh, 92, 5,
                 start+i*length,
                 start+i*length+stop,
                 "100", 100, 1, 1, 1, 0.2)
      circleFill(center, wh, 92, 5,
                 start+i*length,
                 start+i*length+stop,
                 cpuinner, 100, 1, 1, 1, 0.5)

      cpuouter="${cpu cpu" .. i+5 .. "}"
      circleFill(center, wh, 99, 5,
                 start+i*length,
                 start+i*length+stop,
                 "100", 100, 1, 1, 1, 0.2)
      circleFill(center, wh, 99, 5,
                 start+i*length,
                 start+i*length+stop,
                 cpuouter, 100, 1, 1, 1, 0.5)
   end
end

-------------------------------------
-- Prints, and draws, battery information
-------------------------------------
function drawBattery()
   local monitor_flag=conky_parse("${exec cat ~/.cache/wetch/monitor_flag}")

   if monitor_flag == 'false' then
      do return end
   end

   local batteryLevel=tonumber(conky_parse("${battery_percent BAT0}"))
   local r=0.7
   local g=0.7
   local b=1
   if batteryLevel < 15 then
      r=1
      g=0
      b=0
   end

   circleFill(center, wh, 95, 12, 230, 320, "100", 100, r, g, b, 0.2)
   circleFill(center, wh, 95, 12, 230, 320,
              "${battery_percent BAT0}", 100, r, g, b, 0.5)

   isDischargingStr="${if_empty " ..
      "${execi 10 upower -i " ..
      "../org/freedesktop/UPower/devices/battery_BAT0 " ..
   "| grep -o \"discharging\"}}0${else}1${endif}"

   isChargingStr="${if_empty " ..
      " ${execi 10 upower -i " ..
      "/org/freedesktop/UPower/devices/battery_BAT0 " ..
   "| grep -o \"charging\"}}0${else}1${endif}"

   isFullyChargedStr="${if_empty " ..
      "${execi 10 upower -i " ..
      "/org/freedesktop/UPower/devices/battery_BAT0 " ..
   "| grep \"fully-charged\"}}0${else}1${endif}"

   local isDischarging=tonumber(conky_parse(isDischargingStr))
   local isCharging=tonumber(conky_parse(isChargingStr))
   local isFullyCharged=tonumber(conky_parse(isFullyChargedStr))

   if isDischarging == 1 then
      jprint("discharging", center-120, wh+90, 16,
             r, g, b, 1, CAIRO_FONT_WEIGHT_NORMAL)
      jprint(conky_parse("${battery_time BAT0}"), center-130, wh+110, 16,
             r, g, b, 1, CAIRO_FONT_WEIGHT_NORMAL)
   elseif isCharging == 1 then
      jprint("charging", center-120, wh+90, 16,
             r, g, b, 1, CAIRO_FONT_WEIGHT_NORMAL)
      jprint(conky_parse("${battery_time BAT0}"), center-130, wh+110, 16,
             r, g, b, 1, CAIRO_FONT_WEIGHT_NORMAL)
   elseif isFullyCharged == 1 then
      jprint("connected", center-120, wh+90, 16,
             r, g, b, 1, CAIRO_FONT_WEIGHT_NORMAL)
      jprint("fully charged", center-130, wh+110, 16,
             r, g, b, 1, CAIRO_FONT_WEIGHT_NORMAL)
   end
end

-------------------------------------
-- Uses cached data to draw weather icons and weather data
-------------------------------------
function drawWeather()
   local weather_flag=conky_parse("${exec cat ~/.cache/wetch/weather_flag}")

   if weather_flag == 'false' then
      do return end
   end

   local temp=conky_parse("${exec jq .[].Temperature.Metric.Value " ..
                             "~/.cache/wetch/weather.json " ..
                             "| awk '{print int($1+0.5)}'}")

   local clouds=conky_parse("${exec jq .[].CloudCover " ..
                               "~/.cache/wetch/weather.json}")

   local humidity=conky_parse("${exec jq .[].RelativeHumidity " ..
                                 "~/.cache/wetch/weather.json " ..
                                 "| awk '{print int($1+0.5)}'}")

   local wind=conky_parse("${exec jq .[].Wind.Speed.Metric.Value " ..
                             "~/.cache/wetch/weather.json " ..
                             "| awk '{print int($1/3.6)}'}")

   -- Weather text information
   local weathertextx=center+220

   jprint(conky_parse(temp .. " °C"),
          weathertextx, wh+80, 25, 1, 1, 1, 1, CAIRO_FONT_WEIGHT_NORMAL)

   jprint(conky_parse(
             "Feels like " ..
                "${exec jq .[].RealFeelTemperatureShade.Metric.Value " ..
                "~/.cache/wetch/weather.json | awk '{print int($1+0.5)}'} °C"),
          weathertextx, wh+100, 16, 1, 1, 1, 1, CAIRO_FONT_WEIGHT_NORMAL)

   jprint(conky_parse(
             "Clouds " .. clouds .."%"),
          weathertextx, wh+120, 16, 1, 1, 1, 1, CAIRO_FONT_WEIGHT_NORMAL)

   jprint(conky_parse(
             "Humidity " .. humidity .. "%"),
          weathertextx, wh+140, 16, 1, 1, 1, 1, CAIRO_FONT_WEIGHT_NORMAL)

   jprint(conky_parse(
             "Wind " .. wind ..
                " m/s ${exec jq .[].Wind.Direction.Localized " ..
                "~/.cache/wetch/weather.json | cut -d: -f2 | tr -d '\"'}"),
          weathertextx, wh+160, 16, 1, 1, 1, 1, CAIRO_FONT_WEIGHT_NORMAL)

   jprint(conky_parse("Updated ${exec echo $(date -r " ..
                         "~/.cache/wetch/last_weather_update.txt) " ..
                         "| grep -o '[0-9][0-9]:[0-9][0-9]:[0-9][0-9]'}"),
          weathertextx, wh+200, 16, 1, 1, 1, 1, CAIRO_FONT_WEIGHT_NORMAL)

   -- Parse time to determine location of weather icons and set icons
   local x={center+62, center+121, center+144, center+122,
            center+60, center-25, center-110, center-173,
            center-195, center-173, center-110, center-25}

   local y={wh-160, wh-99, wh-15, wh+70,
            wh+133, wh+155, wh+133, wh+70,
            wh-15, wh-99, wh-160, wh-184}

   local jsStr=""
   for i=0, 11, 1 do
      jsStr="${exec jq .[" .. tostring(i) .. "].DateTime ~/.cache/wetch/forecast.json " ..
         "| grep -o T[0-9][0-9] | grep -o [0-9][0-9]}"

      local hourMark=timeModulo(tonumber(conky_parse(jsStr)))

      jimage(conky_parse("/home/${uid_name 1000}/.cache/wetch/forecast-" ..
                            tostring(i+1) ..".png"),
             50, 30, x[hourMark], y[hourMark])
   end

   jimage(conky_parse("/home/${uid_name 1000}/.cache/wetch/weather.png"),
          75, 45, center-38, wh-20)

   -- Weather quality
   local weatherstr=conky_parse("${exec jq .[].WeatherText " ..
                                   "~/.cache/wetch/weather.json " ..
                                   "| cut -d: -f2 | tr -d '\"'}")

   if weatherstr == "Sunny" then
      weatherval=100
   elseif weatherstr == "Mostly sunny" then
      weatherval=95
   elseif weatherstr == "Partly sunny" then
      weatherval=90
   elseif weatherstr == "Intermittent clouds" then
      weatherval=85
   elseif weatherstr == "Hazy sunshine" then
      weatherval=70
   elseif weatherstr == "Mostly cloudy" then
      weatherval=65
   elseif weatherstr == "Cloudy" then
      weatherval=60
   elseif weatherstr == "Fog" then
      weatherval=70
   else
      weatherval=0
   end

   local tempval=100/(1+2.71^(-(tonumber(temp)-13)/5))
   local cloudval=100-clouds
   local humidityval=100/(1+2.71^(-75-tonumber(humidity)/10))
   local windval=10*100/(1+2^(-(3-tonumber(wind))*1.1))
   local weatherval=10*weatherval

   local quality=math.floor(
      (tempval + cloudval + humidityval + windval + weatherval)/23 + 0.5)

   circleFill(center, wh, 130, 6, 265, 330, "100", 100, 1, 1, 1, 0.2)
   circleFill(center, wh, 130, 6, 265, 330, quality, 100, 1, 1, 1, 0.5)

   jprint("weather", center-160, wh+35, 16, 1,
          1, 1, 1, CAIRO_FONT_WEIGHT_NORMAL)

   jprint("Quality " .. quality .. "%", weathertextx, wh+180, 16,
          1, 1, 1, 1, CAIRO_FONT_WEIGHT_NORMAL)

   jline(center+205, wh+60, center+205, wh+200, 3, 1,1,1,0.4)
end

-------------------------------------
-- Calls external script to print currently playing artist and track
-- in Spotify
-------------------------------------

function drawSpotify()
   local isRunning=tonumber(conky_parse("${if_running spotify}1" ..
                                        "${else}0${endif}"))

   if isRunning == 1 then
      jimage(conky_parse("/home/${uid_name 1000}/wetch/spotify-client.png"),
             40, 40, center+200, wh-50)

      jprint(conky_parse("${exec ~/wetch/spotify-artist.sh} - " ..
                            "${exec ~/wetch/spotify-title.sh}"),
             center+245, wh-10, 16, 0.51, 0.74, 0, 1, CAIRO_FONT_WEIGHT_BOLD)
   end
end

-------------------------------------
-- Calls external script to pull number of unread Slack messages
-------------------------------------
function slack()
   local slack_flag=conky_parse("${exec cat ~/.cache/wetch/slack_flag}")

   if slack_flag == 'false' then
      do return end
   end

   local slackx=center+230
   local slacky=wh+15

   jimage(conky_parse("/home/${uid_name 1000}/wetch/slack-web.png"),
          30, 30, slackx-25, slacky)

   local unread=tonumber(conky_parse("${execi 5 ~/wetch/slack.sh}"))

   if unread > 0 then
      circleFill(slackx+4, slacky+5, 3, 7, 0, 360, "100", 100, 0.64, 0, 0, 1)
      cairo_select_font_face(cr, "Droid Sans", CAIRO_FONT_SLANT_NORMAL, face)
      cairo_set_font_size (cr, 10)
      cairo_set_source_rgba (cr, 1, 1, 1, 1)
      cairo_move_to (cr, slackx, slacky+9)
      cairo_show_text (cr, unread)
      cairo_stroke (cr)
   end

end

-------------------------------------
-- Writes text
-- @param str String
-- @param x coordinate
-- @param y coordinate
-- @param fontSize
-- @param r red
-- @param g green
-- @param b blue
-- @param a alpha
-- @param face font face
-------------------------------------
function jprint(str, x, y, fontSize, r, g, b, a, face)
   cairo_select_font_face(cr, "Poiret One", CAIRO_FONT_SLANT_NORMAL, face)
   cairo_set_font_size(cr, fontSize)
   cairo_set_source_rgba(cr, r, g, b, a)
   cairo_move_to(cr, x, y)
   cairo_show_text(cr, str)
   cairo_stroke(cr)
end

-------------------------------------
-- Draws a circle
-- @param x center x coordinate
-- @param y center y coordinate
-- @param rad radius
-- @param width edge width
-- @param deg0 start angle
-- @param deg1 end angle
-- @param cmd conky command for calculating value
-- @param max max value
-- @param r red
-- @param g green
-- @param b blue
-- @param a alpha
-------------------------------------
function circleFill(x, y, rad, width, deg0, deg1, cmd, max, r, g, b, a)
   local value=conky_parse(cmd)
   local end_deg=value*(deg1-deg0)/max + deg0
   cairo_set_line_width(cr,width)
   cairo_set_line_cap(cr, CAIRO_LINE_CAP_SQUARE)
   cairo_set_source_rgba(cr,r,g,b,a)
   cairo_arc(cr,x,y,rad,(deg0-90)*(math.pi/180),(end_deg-90)*(math.pi/180))
   cairo_stroke(cr)
end

-------------------------------------
-- Draws image
-- @param path path to image
-- @param w image width in pixels
-- @param h image height in pixels
-- @param x Upper left corner x coordinate
-- @param y Upper left corner y coordinate
-------------------------------------
function jimage(path, w, h, x, y)
   local image = imlib_load_image(path)
   imlib_context_set_image(image)

   local scaled=imlib_create_cropped_scaled_image(
      0, 0, imlib_image_get_width(),imlib_image_get_height(), w, h)

   imlib_context_set_image(scaled)
   imlib_render_image_on_drawable(x, y)
   imlib_free_image()
end

-------------------------------------
-- Draws a straight line
-- @param x1 x start coordinate
-- @param y1 y start coordinate
-- @param x2 x end coordinate
-- @param y2 y end coordinate
-- @param w line width
-- @param r red
-- @param g green
-- @param b blue
-- @param a alpha
-------------------------------------
function jline(x1, y1, x2, y2, w, r, g, b, a)
   cairo_set_line_width(cr, w)
   cairo_set_line_cap (cr, CAIRO_LINE_CAP_SQUARE)
   cairo_set_source_rgba(cr, r, g, b, a)
   cairo_move_to(cr, x1, y1)
   cairo_line_to(cr, x2, y2)
   cairo_stroke(cr)
end



-------------------------------------
-- Converts 24h format to 12h
-- @param t time in 24h format
-------------------------------------
function timeModulo(t)
   if t == nil then
      return
   end
   if t > 11 then
      t = t-12
   end
   if t == 0 then
      t = 12
   end

   return t
end
