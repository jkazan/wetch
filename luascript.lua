require 'cairo'
require 'imlib2'
-- TODO: Make independant on location of wetch
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

   -- Global variables
   cr = cairo_create(cs)
   font_n=CAIRO_FONT_WEIGHT_NORMAL
   font_b=CAIRO_FONT_WEIGHT_BOLD
   R=0.8
   G=0.8
   B=1
   trans_x=220
   trans_y=conky_window.height/2
   local flags=conky_parse("${execi 999999 cat ~/.cache/wetch/flags}")


   -- Set origin coordinates
   cairo_translate(cr,trans_x,trans_y)

   -- Call functions to draw wetch
   if string.match(flags, "m") then
      draw_centerLine()
      draw_time_circles()
      draw_wifi()
      draw_ram()
      draw_cpu()
      draw_battery()
      draw_spotify()
   end

   draw_date_time()

   if string.match(flags, "s") then
      draw_slack()
   end

   if string.match(flags, "w") then
      draw_weather()
   end

   cairo_destroy(cr)
   cairo_surface_destroy(cs)
   cr=nil
end

function draw_centerLine()
   local x0=220
   local x1=1000
   local gradient_size=150

   linearGradient(-x0, 0, -x0, gradient_size, 1)
   linearGradient(-x0, 0, -x0, -gradient_size, 1)
   jline(x0, 0, x1, 0 ,3 ,R ,G ,B ,0.8)
end

function draw_date_time()
   local x=1050
   local y=70
   jprint(conky_parse("${time %H}:${time %M}"), x, y, 180, 1, 1, 1, 0.7, font_n)
   jprint(conky_parse("${execi 999999 LANG='' LC_TIME='' date +'%A'}"),
          x, y-160, 70, 1, 1, 1, 0.7, font_n)
   jprint(conky_parse("${execi 999999 LANG='' LC_TIME='' date +'%B %d'}"),
          x, y+67, 70, 1, 1, 1, 0.7, font_n)
end

-------------------------------------
-- Prints, and draws, time information
-------------------------------------
function draw_time_circles()
   local x=0
   local y=0
   local H=tonumber(conky_parse("${time %H}"))
   local M=tonumber(conky_parse("${time %M}"))
   local S=tonumber(conky_parse("${time %S}"))
   if H > 11 then
      H = H-12
   end
   local h_meter=H+M/60
   local m_meter=M

   circleFill(x, y, 65, 6, 0, 360, "12", 12, R, G, B, 0.2)
   circleFill(x, y, 65, 7, 0, 360, h_meter, 12, R, G, B, 0.4)

   circleFill(x, y, 76, 4, 0, 360, "60", 60, R, G, B, 0.2)
   circleFill(x, y, 76, 5, 0, 360, m_meter, 60, R, G, B, 0.6)

   local h_point=h_meter/12*360*math.pi/180-math.pi/2
   jline(x, y, x+50*math.cos(h_point), y+50*math.sin(h_point), 7, R, G, B, 0.2)

   local m_point=m_meter/60*360*math.pi/180-math.pi/2
   jline(x, y, x+55*math.cos(m_point), y+55*math.sin(m_point), 5, R, G, B, 0.2)
end

function draw_wifi()
   local x=0
   local y=0
   local wireless=conky_parse("${exec /sbin/ifconfig | egrep -o '^w[^:]+'}")
   local link_qual="${wireless_link_qual " .. wireless .. "}"

   local essid=conky_parse("${exec iwconfig 2>/dev/null " ..
                              "| grep ESSID | cut -d: -f2 | tr -d '\"'}")

   local isConnected=tonumber(conky_parse("${if_existing /proc/net/route " ..
                                          wireless .. "}1${else}0${endif}"))

   if isConnected == 0 or wireless == "" then
      circleFill(x, y, 130, 6, 0, 80, "100", 100, 1, 0, 0, 0.2)
      jprint("wi-fi", x-40, y-125, 16, 1, 0, 0, 1, font_n)
      jprint(conky_parse(essid), x-60, y-140, 14, 1, 0, 0, 1, font_n)
   else
      circleFill(x, y, 130, 6, 0, 80, "100", 100, R, G, B, 0.2)
      circleFill(x, y, 130, 6, 0, 80, link_qual, 100, R, G, B, 0.4)
      jprint("wi-fi", x-40, y-125, 16, R, G, B,1, font_n)
      jprint(conky_parse(essid), x-60, y-140, 14, R, G, B, 1, font_n)
   end
end

-------------------------------------
-- Prints, and draws, ram information
-------------------------------------
function draw_ram()
   local x=0
   local y=0

   local ram_usage=tonumber(conky_parse("${memperc}"))
   local c=get_colors_gt(ram_usage, 80)

   circleFill(x, y, 95, 12, 0, 80, "100", 100, c[1], c[2], c[3], 0.2)
   circleFill(x, y, 95, 12, 0, 80, ram_usage, 100, c[1], c[2], c[3], 0.5)
   jprint("ram", x-40, y-90, 16, c[1], c[2], c[3], 1, font_n)
end

function draw_cpu()
   local x=0
   local y=0

   local cpu_usage=tonumber(conky_parse("${cpu}"))
   local c=get_colors_gt(cpu_usage, 80)

   circleFill(x, y, 130, 6, 120, 200, "100", 100, c[1], c[2], c[3], 0.2)
   circleFill(x, y, 130, 6, 120, 200, cpu_usage, 100, c[1], c[2], c[3], 0.5)
   jprint("cpu", x+105, y+55, 16, c[1], c[2], c[3], 1, font_n)

   local start=100
   local length=26
   local stop=21

   for i=0, 3, 1 do
      local cpuinner="${cpu cpu" .. i+1 .. "}"
      circleFill(x, y, 92, 5,
                 start+i*length,
                 start+i*length+stop,
                 "100", 100, c[1], c[2], c[3], 0.2)
      circleFill(x, y, 92, 5,
                 start+i*length,
                 start+i*length+stop,
                 cpuinner, 100, c[1], c[2], c[3], 0.5)

      local cpuouter="${cpu cpu" .. i+5 .. "}"
      circleFill(x, y, 99, 5,
                 start+i*length,
                 start+i*length+stop,
                 "100", 100, c[1], c[2], c[3], 0.2)
      circleFill(x, y, 99, 5,
                 start+i*length,
                 start+i*length+stop,
                 cpuouter, 100, c[1], c[2], c[3], 0.5)
   end
end

-------------------------------------
-- Prints, and draws, battery information
-------------------------------------
function draw_battery()
   local x=0
   local y=0

   local batteryLevel=tonumber(conky_parse("${battery_percent BAT0}"))
   local c=get_colors_lt(batteryLevel, 15)

   circleFill(x, y, 95, 12, 230, 320, "100", 100, c[1], c[2], c[3], 0.2)
   circleFill(x, y, 95, 12, 230, 320,
              "${battery_percent BAT0}", 100, c[1], c[2], c[3], 0.5)

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
      jprint("discharging", x-120, y+90, 16, c[1], c[2], c[3], 1, font_n)
      jprint(conky_parse("${battery_time BAT0}"), x-130, y+110, 16,
             c[1], c[2], c[3], 1, font_n)
   elseif isCharging == 1 then
      jprint("charging", x-120, y+90, 16, c[1], c[2], c[3], 1, font_n)
      jprint(conky_parse("${battery_time BAT0}"), x-130, y+110, 16,
             c[1], c[2], c[3], 1, font_n)
   elseif isFullyCharged == 1 then
      jprint("connected", x-120, y+90, 16, c[1], c[2], c[3], 1, font_n)
             jprint("fully charged", x-130, y+110, 16, c[1], c[2], c[3], 1, font_n)
   end
end

-------------------------------------
-- Calls external script to print currently playing artist, track and album
-- artwork in Spotify
-------------------------------------
function draw_spotify()
   local x=220
   local y=-10

   local isRunning=tonumber(conky_parse("${if_running spotify}1" ..
                                        "${else}0${endif}"))

   if isRunning == 1 then
      -- Artist
      jprint(conky_parse("${exec ~/wetch/spotify-artist.sh}"),
             x+110, y-20, 16, 0.51, 0.74, 0, 1, CAIRO_FONT_WEIGHT_BOLD)

      -- Title
      jprint(conky_parse("${exec ~/wetch/spotify-title.sh}"),
             x+110, y, 16, 0.51, 0.74, 0, 1, CAIRO_FONT_WEIGHT_BOLD)

      -- Cover (draw album cover without cache for it to update on change)
      conky_parse("${exec  ~/wetch/spotify-cover.sh}")

      local image = imlib_load_image_without_cache(
         conky_parse("/home/${uid_name 1000}/.cache/wetch/current.jpg"))

      imlib_context_set_image(image)

      local scaled=imlib_create_cropped_scaled_image(
         0, 0, imlib_image_get_width(),imlib_image_get_height(), 100, 100)

      imlib_context_set_image(scaled)
      imlib_render_image_on_drawable(trans_x+x, trans_y+y-100)
      imlib_free_image()
   end
end

-------------------------------------
-- Uses cached data to draw weather icons and weather data
-------------------------------------
function draw_weather()
   local x=0
   local y=0
   local txt_font_size=16
   local txt_x=340
   local txt_y=4 + txt_font_size
   local gap_x=90 + 2*txt_font_size
   local gap_y=20

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

   local windStr=conky_parse(wind .. " m/s " ..
                                "${exec jq .[].Wind.Direction.Localized " ..
                                "~/.cache/wetch/weather.json " ..
                                "| cut -d: -f2 | tr -d '\"'}")

   -- Weather text information
   jprint(conky_parse(temp .. " °C"),
          txt_x, txt_y+15, txt_font_size*2, R, G, B, 0.8, font_n)

   jprint("Feels like", txt_x+gap_x, txt_y, txt_font_size, R, G, B, 1, font_n)

   jprint(conky_parse(
             "${exec jq .[].RealFeelTemperatureShade.Metric.Value " ..
                "~/.cache/wetch/weather.json | awk '{print int($1+0.5)}'} °C"),
          txt_x+gap_x, txt_y+gap_y, txt_font_size, R, G, B, 1, font_n)

   jprint("Cloudiness", txt_x+gap_x*2, txt_y, txt_font_size, R, G, B, 1, font_n)
   jprint(clouds .."%",
          txt_x+gap_x*2, txt_y+gap_y, txt_font_size, R, G, B, 1, font_n)

   jprint("Humidity", txt_x+gap_x*3, txt_y, txt_font_size, R, G, B, 1, font_n)
   jprint(humidity .. "%",
          txt_x+gap_x*3, txt_y+gap_y, txt_font_size, R, G, B, 1, font_n)

   jprint("Wind", txt_x+gap_x*4, txt_y, txt_font_size, R, G, B, 1, font_n)
   jprint(windStr, txt_x+gap_x*4, txt_y+gap_y, txt_font_size,
          R, G, B, 1, font_n)

   -- Parse time to determine location of weather icons and set icons
   -- Must need trans_x and trans_y as imlib does not know translation
   local icon_x={trans_x+x+62, trans_x+x+121, trans_x+x+144, trans_x+x+122,
                 trans_x+x+60, trans_x+x-25, trans_x+x-110, trans_x+x-173,
                 trans_x+x-195, trans_x+x-173, trans_x+x-110, trans_x+x-25}

   local icon_y={trans_y+y-160, trans_y+y-99, trans_y+y-15, trans_y+y+70,
                 trans_y+y+133, trans_y+y+155, trans_y+y+133, trans_y+y+70,
                 trans_y+y-15, trans_y+y-99, trans_y+y-160, trans_y+y-184}

   local jsStr=""
   for i=0, 11, 1 do
      jsStr="${exec jq .[" .. tostring(i) ..
         "].DateTime ~/.cache/wetch/forecast.json " ..
         "| grep -o T[0-9][0-9] | grep -o [0-9][0-9]}"

      local hourMark=timeModulo(tonumber(conky_parse(jsStr)))

      jimage(conky_parse("/home/${uid_name 1000}/.cache/wetch/forecast-" ..
                            tostring(i) ..".png"),
             50, 30, icon_x[hourMark], icon_y[hourMark])
   end

   jimage(conky_parse("/home/${uid_name 1000}/.cache/wetch/weather.png"),
          75, 45, trans_x+x-38, trans_y+y-20)

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

   local c=get_colors_lt(quality, 30)

   circleFill(x, y, 130, 6, 265, 330, "100", 100, c[1], c[2], c[3], 0.2)
   circleFill(x, y, 130, 6, 265, 330, quality, 100, c[1], c[2], c[3], 0.5)

   jprint("weather", x-160, y+35, 16, c[1], c[2], c[3], 1, font_n)

   jprint("Quality " , txt_x+gap_x*5, txt_y, txt_font_size, R, G, B, 1, font_n)
   jprint(quality .. "%", txt_x+gap_x*5, txt_y+gap_y, txt_font_size,
          R, G, B, 1, font_n)
end

-------------------------------------
-- Calls external script to pull number of unread Slack messages
-------------------------------------
function draw_slack()
   local x=250
   local y=10

   jimage(conky_parse("/home/${uid_name 1000}/wetch/slack-web.png"),
          30, 30, trans_x+x-25, trans_y+y)

   local unread=tonumber(conky_parse("${execi 5 ~/wetch/slack.sh}"))

   if unread > 0 then
      circleFill(x+4, y+5, 5, 9, 0, 360, "100", 100, 0.64, 0, 0, 1)

      cairo_select_font_face(cr, "Droid Sans", font_b, face)
      cairo_set_font_size (cr, 13)
      cairo_set_source_rgba (cr, 1, 1, 1, 1)
      cairo_move_to (cr, x, y+9)
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

-------------------------------------
-- Draws linear gradient
-- @param x0 start x coordinate
-- @param y0 start y coordinate
-- @param x1 end x coordinate
-- @param y1 end y coordinate
-- @param intensity color intensity
-------------------------------------
function linearGradient(x0, y0, x1, y1, intensity)
   for i=1, intensity, 1 do
      local pat=cairo_pattern_create_linear (x0, y0, x1, y1);
      cairo_pattern_add_color_stop_rgba (pat, 1, 0, 0, 0, 0.0);
      cairo_pattern_add_color_stop_rgba (pat, 0, 0, 0, 0, 0.9);
      cairo_rectangle (cr, x0, y0, conky_window.width/2*5, y1-y0);
      cairo_set_source (cr, pat);
      cairo_fill (cr);
      cairo_pattern_destroy (pat);
      cairo_stroke (cr)
   end
end


-------------------------------------
-- Returns rgb color array: Warning color if a<b else globally defined rgb
-- @param a value to be tested
-- @param b limit for warning color
-------------------------------------
function get_colors_lt(a, b)
   local colors={R, G, B}
   if a < b then
      colors={1, 0, 0}
   end
   return colors
end

-------------------------------------
-- Returns rgb color array: Warning color if a>b else globally defined rgb
-- @param a value to be tested
-- @param b limit for warning color
-------------------------------------
function get_colors_gt(a, b)
   local colors={R, G, B}
   if a > b then
      colors={1, 0, 0}
   end
   return colors
end
