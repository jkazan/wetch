require 'cairo'
require 'imlib2'

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

    drawTime()
    drawDate()
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

function drawTime()
     H=tonumber(conky_parse("${time %H}"))
     M=tonumber(conky_parse("${time %M}"))
     S=tonumber(conky_parse("${time %S}"))
     if H > 11 then
        H = H-12
     end
     hourMeter=H+M/60
     minuteMeter=M
     --minuteMeter=M+S/60

     circleFill(center, wh, 65, 6, 0, 360, "12", 12, 1, 1, 1, 0.2)
     circleFill(center, wh, 65, 7, 0, 360, hourMeter, 12, 1, 1, 1, 0.4)

     circleFill(center, wh, 76, 4, 0, 360, "60", 60, 1, 1, 1, 0.2)
     circleFill(center, wh, 76, 5, 0, 360, minuteMeter, 60, 1, 1, 1, 0.6)

     --circleFill(center, wh, 60, 5, 0, 360, "60", 60, 1, 1, 1, 0.2)
     --circleFill(center, wh, 60, 6, 0, 360, "${time %S}", 60, 1, 1, 1, 0.2)

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


     jprint(conky_parse("${time %H}:${time %M}"), center+920, wh+70, 200, 1, 1, 1, 0.8, CAIRO_FONT_WEIGHT_NORMAL)
    end

function drawDate()
    jline(center+200, wh, center+900, wh, 3, 1,1,1,0.8)
    jprint(conky_parse("${execi 300 LANG='' LC_TIME='' date +'%A'}"),
           center+920, wh-100, 80, 1, 1, 1, 0.8, CAIRO_FONT_WEIGHT_NORMAL)
    jprint(conky_parse("${execi 300 LANG='' LC_TIME='' date +'%B %d'}"),
           center+920, wh+160, 80, 1, 1, 1, 0.8, CAIRO_FONT_WEIGHT_NORMAL)
end

function drawWifi()
    wireless=conky_parse("${exec /sbin/ifconfig | egrep -o '^w[^:]+'}")
    link_qual="${wireless_link_qual " .. wireless .. "}"
    essid=conky_parse("${exec iwconfig 2>/dev/null | grep ESSID | cut -d: -f2 | tr -d '\"'}")
    isConnectedStr="${if_existing /proc/net/route " .. wireless .. "}1${else}0${endif}"
    isConnected=tonumber(conky_parse(isConnectedStr))

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

function drawRamCpu()
    circleFill(center, wh, 130, 6, 120, 200, "100", 100, 1, 1, 1, 0.2)
    circleFill(center, wh, 130, 6, 120, 200, "${cpu}", 100, 1, 1, 1, 0.5)
    jprint("cpu", center+105, wh+55, 16, 1, 1, 1, 1, CAIRO_FONT_WEIGHT_NORMAL)


    circleFill(center, wh, 95, 12, 0, 80, "100", 100, 1, 1, 1, 0.2)
    circleFill(center, wh, 95, 12, 0, 80, "${memperc}", 100, 1, 1, 1, 0.5)
    jprint("ram", center-40, wh-90, 16, 1, 1, 1, 1, CAIRO_FONT_WEIGHT_NORMAL)

    start=100
    length=26
    stop=21
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

function drawBattery()
jprint(conky_parse("${execi 300 ~/wetch/batnot.sh}"),
       center+210,
       wh,
       16, 0.51, 0.74, 0, 1,
       CAIRO_FONT_WEIGHT_BOLD)
    batteryLevel=tonumber(conky_parse("${battery_percent BAT0}"))
    r=0.7
    g=0.7
    b=1
    if batteryLevel < 15 then
       r=1
       g=0
       b=0
    end

    circleFill(center, wh, 95, 12, 230, 320, "100", 100, r, g, b, 0.2)
    circleFill(center, wh, 95, 12, 230, 320,
               "${battery_percent BAT0}", 100, r, g, b, 0.5)

    isDischarging=tonumber(conky_parse("${if_empty ${execi 10 upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -o \"discharging\"}}0${else}1${endif}"))
    isCharging=tonumber(conky_parse("${if_empty ${execi 10 upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -o \"charging\"}}0${else}1${endif}"))
    isFullyCharged=tonumber(conky_parse("${if_empty ${execi 10 upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep \"fully-charged\"}}0${else}1${endif}"))
    if isDischarging == 1 then
        jprint("discharging", center-120, wh+90, 16, r, g, b, 1, CAIRO_FONT_WEIGHT_NORMAL)
        jprint(conky_parse("${battery_time BAT0}"), center-130, wh+110, 16, r, g, b, 1, CAIRO_FONT_WEIGHT_NORMAL)
    elseif isCharging == 1 then
        jprint("charging", center-120, wh+90, 16, r, g, b, 1, CAIRO_FONT_WEIGHT_NORMAL)
        jprint(conky_parse("${battery_time BAT0}"), center-130, wh+110, 16, r, g, b, 1, CAIRO_FONT_WEIGHT_NORMAL)
    elseif isFullyCharged == 1 then
        jprint("connected", center-120, wh+90, 16, r, g, b, 1, CAIRO_FONT_WEIGHT_NORMAL)
        jprint("fully charged", center-130, wh+110, 16, r, g, b, 1, CAIRO_FONT_WEIGHT_NORMAL)
    end
end

function drawWeather()
    temp=conky_parse("${exec jq .[].Temperature.Metric.Value ~/.cache/wetch/weather.json | awk '{print int($1+0.5)}'}")
    clouds=conky_parse("${exec jq .[].CloudCover ~/.cache/wetch/weather.json}")
    humidity=conky_parse("${exec jq .[].RelativeHumidity ~/.cache/wetch/weather.json | awk '{print int($1+0.5)}'}")
    wind=conky_parse("${exec jq .[].Wind.Speed.Metric.Value ~/.cache/wetch/weather.json | awk '{print int($1/3.6)}'}")
    weathertextx=center+220
    -- Weather text information
    jprint(conky_parse(temp .. " °C"),
           weathertextx, wh+80, 25, 1, 1, 1, 1, CAIRO_FONT_WEIGHT_NORMAL)
    jprint(conky_parse(
           "Feels like ${exec jq .[].RealFeelTemperatureShade.Metric.Value ~/.cache/wetch/weather.json | awk '{print int($1+0.5)}'} °C"),
           weathertextx, wh+100, 16, 1, 1, 1, 1, CAIRO_FONT_WEIGHT_NORMAL)
    jprint(conky_parse(
           "Clouds " .. clouds .."%"),
           weathertextx, wh+120, 16, 1, 1, 1, 1, CAIRO_FONT_WEIGHT_NORMAL)
    jprint(conky_parse(
           "Humidity " .. humidity .. "%"),
           weathertextx, wh+140, 16, 1, 1, 1, 1, CAIRO_FONT_WEIGHT_NORMAL)
    jprint(conky_parse(
           "Wind " .. wind .. " m/s ${exec jq .[].Wind.Direction.Localized ~/.cache/wetch/weather.json | cut -d: -f2 | tr -d '\"'}"),
           weathertextx, wh+160, 16, 1, 1, 1, 1, CAIRO_FONT_WEIGHT_NORMAL)
    jprint("Updated " .. conky_parse("${exec echo $(date -r ~/.cache/wetch/last_weather_update.txt) | grep -o '[0-9][0-9]:[0-9][0-9]:[0-9][0-9]'}"),
           weathertextx, wh+200, 16, 1, 1, 1, 1, CAIRO_FONT_WEIGHT_NORMAL)

    -- Parse time to determine location of weather icons
    h1=timeModulo(tonumber(conky_parse("${exec jq .[0].DateTime ~/.cache/wetch/forecast.json | grep -o T[0-9][0-9] | grep -o [0-9][0-9]}")))
    h2=timeModulo(tonumber(conky_parse("${exec jq .[1].DateTime ~/.cache/wetch/forecast.json | grep -o T[0-9][0-9] | grep -o [0-9][0-9]}")))
    h3=timeModulo(tonumber(conky_parse("${exec jq .[2].DateTime ~/.cache/wetch/forecast.json | grep -o T[0-9][0-9] | grep -o [0-9][0-9]}")))
    h4=timeModulo(tonumber(conky_parse("${exec jq .[3].DateTime ~/.cache/wetch/forecast.json | grep -o T[0-9][0-9] | grep -o [0-9][0-9]}")))
    h5=timeModulo(tonumber(conky_parse("${exec jq .[4].DateTime ~/.cache/wetch/forecast.json | grep -o T[0-9][0-9] | grep -o [0-9][0-9]}")))
    h6=timeModulo(tonumber(conky_parse("${exec jq .[5].DateTime ~/.cache/wetch/forecast.json | grep -o T[0-9][0-9] | grep -o [0-9][0-9]}")))
    h7=timeModulo(tonumber(conky_parse("${exec jq .[6].DateTime ~/.cache/wetch/forecast.json | grep -o T[0-9][0-9] | grep -o [0-9][0-9]}")))
    h8=timeModulo(tonumber(conky_parse("${exec jq .[7].DateTime ~/.cache/wetch/forecast.json | grep -o T[0-9][0-9] | grep -o [0-9][0-9]}")))
    h9=timeModulo(tonumber(conky_parse("${exec jq .[8].DateTime ~/.cache/wetch/forecast.json | grep -o T[0-9][0-9] | grep -o [0-9][0-9]}")))
    h10=timeModulo(tonumber(conky_parse("${exec jq .[9].DateTime ~/.cache/wetch/forecast.json | grep -o T[0-9][0-9] | grep -o [0-9][0-9]}")))
    h11=timeModulo(tonumber(conky_parse("${exec jq .[10].DateTime ~/.cache/wetch/forecast.json | grep -o T[0-9][0-9] | grep -o [0-9][0-9]}")))
    h12=timeModulo(tonumber(conky_parse("${exec jq .[11].DateTime ~/.cache/wetch/forecast.json | grep -o T[0-9][0-9] | grep -o [0-9][0-9]}")))

    -- Weather icons
    x = {center+62, center+121, center+144, center+122, center+60, center-25, center-110, center-173, center-195, center-173, center-110, center-25}
    y = {wh-160, wh-99, wh-15, wh+70, wh+133, wh+155, wh+133, wh+70, wh-15, wh-99, wh-160, wh-184}

    jimage(conky_parse("/home/${uid_name 1000}/.cache/wetch/weather.png"), 75, 45, center-38, wh-20)
    jimage(conky_parse("/home/${uid_name 1000}/.cache/wetch/forecast-1.png"), 50, 30, x[h1], y[h1])
    jimage(conky_parse("/home/${uid_name 1000}/.cache/wetch/forecast-2.png"), 50, 30, x[h2], y[h2])
    jimage(conky_parse("/home/${uid_name 1000}/.cache/wetch/forecast-3.png"), 50, 30, x[h3], y[h3])
    jimage(conky_parse("/home/${uid_name 1000}/.cache/wetch/forecast-4.png"), 50, 30, x[h4], y[h4])
    jimage(conky_parse("/home/${uid_name 1000}/.cache/wetch/forecast-5.png"), 50, 30, x[h5], y[h5])
    jimage(conky_parse("/home/${uid_name 1000}/.cache/wetch/forecast-6.png"), 50, 30, x[h6], y[h6])
    jimage(conky_parse("/home/${uid_name 1000}/.cache/wetch/forecast-7.png"), 50, 30, x[h7], y[h7])
    jimage(conky_parse("/home/${uid_name 1000}/.cache/wetch/forecast-8.png"), 50, 30, x[h8], y[h8])
    jimage(conky_parse("/home/${uid_name 1000}/.cache/wetch/forecast-9.png"), 50, 30, x[h9], y[h9])
    jimage(conky_parse("/home/${uid_name 1000}/.cache/wetch/forecast-10.png"), 50, 30, x[h10], y[h10])
    jimage(conky_parse("/home/${uid_name 1000}/.cache/wetch/forecast-11.png"), 50, 30, x[h11], y[h11])
    jimage(conky_parse("/home/${uid_name 1000}/.cache/wetch/forecast-12.png"), 50, 30, x[h12], y[h12])

    -- Weather quality
    weatherstr=conky_parse("${exec jq .[].WeatherText ~/.cache/wetch/weather.json | cut -d: -f2 | tr -d '\"'}")

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

    tempval=100/(1+2.71^(-(tonumber(temp)-13)/5))
    cloudval=100-clouds
    humidityval=100/(1+2.71^(-(75-tonumber(humidity))/10))
    windval=10*100/(1+2^(-(3-tonumber(wind))*1.1))
    weatherval=10*weatherval
    quality=math.floor( (tempval + cloudval + humidityval + windval + weatherval)/23 + 0.5)
    circleFill(center, wh, 130, 6, 265, 330, "100", 100, 1, 1, 1, 0.2)
    circleFill(center, wh, 130, 6, 265, 330, quality, 100, 1, 1, 1, 0.5)
    jprint("weather", center-160, wh+35, 16, 1, 1, 1, 1, CAIRO_FONT_WEIGHT_NORMAL)
    jprint("Quality " .. quality .. "%", weathertextx, wh+180, 16, 1, 1, 1, 1, CAIRO_FONT_WEIGHT_NORMAL)

    jline(center+205, wh+60, center+205, wh+200, 3, 1,1,1,0.4)
end

function drawSpotify()
    isRunning=tonumber(conky_parse("${if_running spotify}1${else}0${endif}"))
    if isRunning == 1 then
       jimage(conky_parse("/home/${uid_name 1000}/wetch/spotify-client.png"), 40, 40, center+200, wh-50)
       jprint(conky_parse("${exec ~/wetch/spotify-artist.sh} - ${exec ~/wetch/spotify-title.sh}"), center+245, wh-10, 16, 0.51, 0.74, 0, 1, CAIRO_FONT_WEIGHT_BOLD)
    end
end

function drawWorkspace()
    jprint("ws", ww-20, wh-140, 16, 1, 1, 1, 0.8, CAIRO_FONT_WEIGHT_BOLD)
    jprint(conky_parse("${exec wmctrl -d | grep '*' | cut -c 1}"), ww, wh-140, 16, 1, 1, 1, 0.8, CAIRO_FONT_WEIGHT_BOLD)
end

function slack()
    slackx=center+230
    slacky=wh+15
    jimage(conky_parse("/home/${uid_name 1000}/wetch/slack-web.png"), 30, 30, slackx-25, slacky)
    unread=tonumber(conky_parse("${execi 5 ~/wetch/slack.sh}"))

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

function jprint(str, x, y, fontSize, r, g, b, a, face)
    cairo_select_font_face(cr, "Poiret One", CAIRO_FONT_SLANT_NORMAL, face)
    cairo_set_font_size (cr, fontSize)
    cairo_set_source_rgba (cr, r, g, b, a)
    cairo_move_to (cr, x, y)
    cairo_show_text (cr, str)
    cairo_stroke (cr)
end

function circleFill(x, y, radius, width, deg0, deg1, cmd, max, r, g, b, a)
    value=conky_parse(cmd)
    end_angle=value*(deg1-deg0)/max + deg0
    cairo_set_line_width (cr,width)
    cairo_set_line_cap  (cr, CAIRO_LINE_CAP_SQUARE)
    cairo_set_source_rgba (cr,r,g,b,a)
    cairo_arc (cr,x,y,radius,(deg0-90)*(math.pi/180),(end_angle-90)*(math.pi/180))
    cairo_stroke (cr)
end

function circleStep(x, y, radius, width, cmd, max, r, g, b, a)
    value=conky_parse(cmd)
    start_angle=value*(360/max)-1
    end_angle=value*(360/max)+1
    cairo_set_line_width (cr,width)
    cairo_set_source_rgba (cr,r,g,b,a)
    cairo_arc (cr,x,y,radius,(start_angle-90)*(math.pi/180),(end_angle-90)*(math.pi/180))
    cairo_stroke (cr)
end

function jimage(path, w, h, x, y)
    local image = imlib_load_image(path)
    imlib_context_set_image(image)
    local scaled=imlib_create_cropped_scaled_image(0, 0, imlib_image_get_width(), imlib_image_get_height(), w, h)
    imlib_context_set_image(scaled)
    imlib_render_image_on_drawable(x, y)
    imlib_free_image()
end

function jline(x1, y1, x2, y2, w, r, g, b, a)
    cairo_set_line_width (cr, w)
    cairo_set_line_cap  (cr, CAIRO_LINE_CAP_SQUARE)
    cairo_set_source_rgba (cr, r, g, b, a)
    cairo_move_to (cr, x1, y1)
    cairo_line_to (cr, x2, y2)
    cairo_stroke (cr)
end

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
