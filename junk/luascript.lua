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


   cr = cairo_create(cs)

   font_n=CAIRO_FONT_WEIGHT_NORMAL
   font_b=CAIRO_FONT_WEIGHT_BOLD
   R=0.8
   G=0.8
   B=1
   badR=0.3
   badG=0
   badB=0
   fs = 15

   local flags=conky_parse("${execi 999999 cat ~/.cache/wetch/flags}")
   panel()
   cairo_destroy(cr)
   cairo_surface_destroy(cs)
   cr=nil
end


function panel()
   local x = 0
   local y = fs

   -- Time
   jprint(cr, conky_parse("${time %H}:${time %M}"),
          conky_window.width-50, y, fs, 1, 1, 1, 0.7, font_n)

   -- Date
   jprint(cr, conky_parse("${execi 999999 LANG='' LC_TIME='' date +'%A %B %d'}"),
          conky_window.width-250, y, fs, 1, 1, 1, 0.7, font_n)

   -- -- Day
   -- -- jprint(cr, conky_parse("${execi 999999 LANG='' LC_TIME='' date +'%A'}"),
   -- --        x, y+30, fs, 1, 1, 1, 0.7, font_n)

   -- Wi-fi
   local wireless=conky_parse("${execi 1 /sbin/ifconfig | egrep -o '^w[^:]+'}")
   local link_qual=tonumber(conky_parse("${wireless_link_qual " .. wireless .. "}"))
   local cw=get_colors_lt(link_qual, 35)

   local essid=conky_parse("${exec iwconfig 2>/dev/null " ..
                              "| grep ESSID | cut -d: -f2 | tr -d '\"'}")

   jprint(cr, "wi-fi: " .. essid .. link_qual .. "%",
          0, y, fs, cw[1], cw[2], cw[3], 0.7, font_n)

   -- Battery
   local batteryLevel=tonumber(conky_parse("${battery_percent BAT0}"))
   local cb=get_colors_lt(batteryLevel, 15)

   jprint(cr, "battery: " .. batteryLevel .. "%",
          300, y, fs, cb[1], cb[2], cb[3], 0.7, font_n)

   -- Cpu
   local cpu_usage=tonumber(conky_parse("${cpu}"))
   local cc=get_colors_gt(cpu_usage, 80)
   jprint(cr, "cpu: " .. cpu_usage .. "%",
          450, y, fs, cc[1], cc[2], cc[3], 0.7, font_n)

   -- Ram
   local ram_usage=tonumber(conky_parse("${memperc}"))
   local cra=get_colors_gt(ram_usage, 80)
   jprint(cr, "ram: " .. ram_usage .. "%",
          570, y, fs, cra[1], cra[2], cra[3], 0.7, font_n)

   -- File system usage
   jprint(cr, conky_parse("Used space: " .. "${fs_used_perc}%"),
          700, y, fs, R, G, B, 0.7, font_n)

   -- Bluetooth
   local slaveAuth = conky_parse("${exec hcitool con | grep -o 'SLAVE AUTH'}")
   if slaveAuth == "SLAVE AUTH" then
      jprint(cr, "bt", 900, y, fs, R, G, B, 0.7, font_n)
   else
      jprint(cr, "bt", 900, y, fs, 1, 0, 0, 0.7, font_n)
   end

   -- IP
   jprint(cr,conky_parse("wlp6s0: " .. "${addr wlp6s0}" .. "  enp0s31f6: " .. "${addr enp0s31f6}"),
          conky_window.width-700, y, fs, R, G, B, 0.7, font_n)

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

   circleFill(cr, x, y, 115, 40, 8, 348, "12", 12, R, G, B, 0.2)
   circleFill(cr, x, y, 115, 40, 8, 348, h_meter, 12, R, G, B, 0.4)

   circleFill(cr, x, y, 65, 10, 0, 360, "60", 60, R, G, B, 0.2)
   circleFill(cr, x, y, 65, 12, 0, 360, m_meter, 60, R, G, B, 0.6)

   local h_point=h_meter/12*360*math.pi/180-math.pi/2
   jline(cr, x, y, x+50*math.cos(h_point), y+50*math.sin(h_point), 10, R, G, B, 0.2)

   local m_point=m_meter/60*360*math.pi/180-math.pi/2
   jline(cr, x, y, x+55*math.cos(m_point), y+55*math.sin(m_point), 7, R, G, B, 0.2)

   jimage(cr, conky_parse("/home/${uid_name 1000}/Pictures/clock.png"),
          0.14, 0.14, x-175, y-175)
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
      circleFill(cr_wifi, x, y, 120, 10, 45, 180, "100", 100, 1, 0, 0, 0.2)
      jprint(cr_wifi, "wi-fi", x+110, y-80, 40, 1, 0, 0, 1, font_n)
      jprint(cr_wifi, conky_parse(essid), x-60, y-140, 14, 1, 0, 0, 1, font_n)
   else
      circleFill(cr_wifi, x, y, 120, 10, 45, 180, "100", 100, R, G, B, 0.2)
      circleFill(cr_wifi, x, y, 120, 10, 45, 180, link_qual, 100, R, G, B, 0.4)
      jprint(cr_wifi, "wi-fi", x+110, y-80, 40, R, G, B,1, font_n)
      jprint(cr_wifi, conky_parse(essid), x+125, y-50, 24, R, G, B, 1, font_n)
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

   circleFill(cr_ram, x, y, 150, 30, 0, 360, "100", 100, c[1], c[2], c[3], 0.2)
   circleFill(cr_ram, x, y, 150, 30, 0, 360, ram_usage, 100, c[1], c[2], c[3], 0.5)
   jprint(cr_ram, "ram", x+160, y-90, 50, c[1], c[2], c[3], 1, font_n)

   -- jimage(cr_ram, conky_parse("/home/${uid_name 1000}/Pictures/test.png"),
   --        0.9, 0.9, x-135, y-135)
   -- cairo_set_source_rgba(cr_ram, 0.0, 0.0, 0.0, 0.5)
end

function draw_cpu()
   local x=0
   local y=0

   local cpu_usage=tonumber(conky_parse("${cpu}"))
   local c=get_colors_gt(cpu_usage, 80)

   circleFill(cr_cpu, x, y, 240, 14, 0, 360, "100", 100, c[1], c[2], c[3], 0.2)
   circleFill(cr_cpu, x, y, 240, 14, 0, 360, cpu_usage, 100, c[1], c[2], c[3], 0.5)
   jprint(cr_cpu, "cpu", x+170, y-200, 50, c[1], c[2], c[3], 1, font_n)

   local start=0
   local length=210/4 - 3
   local stop=40

   for i=0, 3, 1 do
      local cpuinner="${cpu cpu" .. i+1 .. "}"
      circleFill(cr_cpu, x, y, 150, 12,
                 start+i*length,
                 start+i*length+stop,
                 "100", 100, c[1], c[2], c[3], 0.2)
      circleFill(cr_cpu, x, y, 150, 12,
                 start+i*length,
                 start+i*length+stop,
                 cpuinner, 100, c[1], c[2], c[3], 0.5)

      local cpuouter="${cpu cpu" .. i+5 .. "}"
      circleFill(cr_cpu, x, y, 180, 12,
                 start+i*length,
                 start+i*length+stop,
                 "100", 100, c[1], c[2], c[3], 0.2)
      circleFill(cr_cpu, x, y, 180, 12,
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

   circleFill(cr, x, y, 115, 40, 8, 348, "100", 12, R, G, B, 0.2)
   circleFill(cr, x, y, 115, 40, 8, 348, "${battery_percent BAT0}", 12, R, G, B, 0.4)
   -- circleFill(cr, x, y, 320, 28, 150, 370, "100", 100, c[1], c[2], c[3], 0.2)
   -- circleFill(cr, x, y, 320, 28, 150, 370,
   --            "${battery_percent BAT0}", 100, c[1], c[2], c[3], 0.5)

   -- isDischargingStr="${if_empty " ..
   --    "${execi 10 upower -i " ..
   --    "/org/freedesktop/UPower/devices/battery_BAT0 " ..
   -- "| grep -o \"discharging\"}}0${else}1${endif}"

   -- isChargingStr="${if_empty " ..
   --    " ${execi 10 upower -i " ..
   --    "/org/freedesktop/UPower/devices/battery_BAT0 " ..
   -- "| grep -o \"charging\"}}0${else}1${endif}"

   -- isFullyChargedStr="${if_empty " ..
   --    "${execi 10 upower -i " ..
   --    "/org/freedesktop/UPower/devices/battery_BAT0 " ..
   -- "| grep \"fully-charged\"}}0${else}1${endif}"

   -- local isDischarging=tonumber(conky_parse(isDischargingStr))
   -- local isCharging=tonumber(conky_parse(isChargingStr))
   -- local isFullyCharged=tonumber(conky_parse(isFullyChargedStr))

   -- jprint(cr, "battery", 90, -300, 50, c[1], c[2], c[3], 1, font_n)
   -- x=x+260
   -- y=y-320

   -- if isDischarging == 1 then
   --    jprint(cr, "discharging", x, y+10, 30, c[1], c[2], c[3], 1, font_n)
   --    jprint(cr, conky_parse("${battery_time BAT0}"), x, y+40, 30,
   --           c[1], c[2], c[3], 1, font_n)
   -- elseif isCharging == 1 then
   --    jprint(cr, "charging", x, y+10, 30, c[1], c[2], c[3], 1, font_n)
   --    jprint(cr, conky_parse("${battery_time BAT0}"), x, y+40, 30,
   --           c[1], c[2], c[3], 1, font_n)
   -- elseif isFullyCharged == 1 then
   --    jprint(cr, "connected", x, y+10, 30, c[1], c[2], c[3], 1, font_n)
   --    jprint(cr, "fully charged", x, y+40, 30, c[1], c[2], c[3], 1, font_n)
   -- end
end

-------------------------------------
-- Calls external script to print currently playing artist, track and album
-- artwork in Spotify
-------------------------------------
function draw_spotify()
   local x=0
   local y=0

   local isRunning=tonumber(conky_parse("${if_running spotify}1" ..
                                        "${else}0${endif}"))

   if isRunning == 1 then
      -- Cover (draw album cover without cache for it to update on change)
      conky_parse("${exec  ~/wetch/spotify-cover.sh}")

      jimage(cr_spotify, conky_parse("/home/${uid_name 1000}/.cache/wetch/current.png"),
             0.8, 0.8, x, y)

      -- Artist
      jprint(cr_spotify, conky_parse("${exec ~/wetch/spotify-artist.sh}"),
             x, y+340, 35, 0.51, 0.74, 0, 1, CAIRO_FONT_WEIGHT_NORMAL)

      -- Title
      jprint(cr_spotify, conky_parse("${exec ~/wetch/spotify-title.sh}"),
             x, y+380, 35, 0.51, 0.74, 0, 1, CAIRO_FONT_WEIGHT_NORMAL)
   end
end

-------------------------------------
-- Uses cached data to draw weather icons and weather data
-------------------------------------
function draw_weather()
   local x=0
   local y=0
   local txt_font_size=24
   local txt_x=-160
   local txt_y=-180 + txt_font_size
   local gap_x=70 + 2*txt_font_size
   local gap_y=80

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

   local windStr=conky_parse(wind .. " m/s")

   local windDirStr=conky_parse("${exec jq .[].Wind.Direction.Localized " ..
                                "~/.cache/wetch/weather.json " ..
                                "| cut -d: -f2 | tr -d '\"'}")

   jprint(cr_weather, "weather", txt_x+200, txt_y-60, 50, R, G, B, 1, font_n)
   -- Weather text information
   jprint(cr_weather, conky_parse(temp .. "°C"),
          txt_x-40, txt_y-gap_y+txt_font_size, txt_font_size*2, R, G, B, 0.8, font_n)

   jprint(cr_weather, "Feels like", txt_x-110, txt_y, txt_font_size, R, G, B, 1, font_n)
   jprint(cr_weather, conky_parse(
             "${exec jq .[].RealFeelTemperatureShade.Metric.Value " ..
                "~/.cache/wetch/weather.json | awk '{print int($1+0.5)}'} °C"),
          txt_x-110, txt_y+txt_font_size, txt_font_size, R, G, B, 1, font_n)

   jprint(cr_weather, "Cloudiness", txt_x-150, txt_y+gap_y, txt_font_size, R, G, B, 1, font_n)
   jprint(cr_weather, clouds .."%",
          txt_x-150, txt_y+gap_y+txt_font_size, txt_font_size, R, G, B, 1, font_n)

   jprint(cr_weather, "Humidity", txt_x-160, txt_y+gap_y*2, txt_font_size, R, G, B, 1, font_n)
   jprint(cr_weather, humidity .. "%",
          txt_x-160, txt_y+gap_y*2+txt_font_size, txt_font_size, R, G, B, 1, font_n)

   jprint(cr_weather, "Wind", txt_x-150, txt_y+gap_y*3, txt_font_size, R, G, B, 1, font_n)
   jprint(cr_weather, windStr, txt_x-150, txt_y+gap_y*3+txt_font_size, txt_font_size,
          R, G, B, 1, font_n)
   jprint(cr_weather, windDirStr, txt_x-150, txt_y+gap_y*3+txt_font_size*2, txt_font_size,
          R, G, B, 1, font_n)

   -- Parse time to determine location of weather icons and set icons
   -- Must need trans_x and trans_y as imlib does not know translation
   local x = -785
   local y = -415
   local scale = 0.8
   local icon_x={x+62, x+121, x+144, x+122,
                 x+60, x-25, x-110, x-173,
                 x-195, x-173, x-110, x-25}

   local icon_y={y-160, y-99, y-15, y+70,
                 y+133, y+155, y+133, y+70,
                 y-15, y-99, y-160, y-184}

   local jsStr=""
   for i=0, 11, 1 do
      jsStr="${exec jq .[" .. tostring(i) ..
         "].DateTime ~/.cache/wetch/forecast.json " ..
         "| grep -o T[0-9][0-9] | grep -o [0-9][0-9]}"

      local hourMark=timeModulo(tonumber(conky_parse(jsStr)))
      jimage(crim[i+1], conky_parse("/home/${uid_name 1000}/.cache/wetch/forecast-" ..
                            tostring(i) ..".png"),
             scale, scale, icon_x[hourMark]-75*scale/10, icon_y[hourMark]-45*scale/5)
   end

   jimage(cr, conky_parse("/home/${uid_name 1000}/.cache/wetch/weather.png"),
          1, 1, x-75/2, y-45/2)

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

   -- circleFill(x, y, 130, 6, 265, 330, "100", 100, c[1], c[2], c[3], 0.2)
   -- circleFill(x, y, 130, 6, 265, 330, quality, 100, c[1], c[2], c[3], 0.5)

   -- jprint("weather", x-160, y+35, 16, c[1], c[2], c[3], 1, font_n)

   -- jprint("Quality " , txt_x+gap_x*5, txt_y, txt_font_size, R, G, B, 1, font_n)
   -- jprint(quality .. "%", txt_x+gap_x*5, txt_y+gap_y, txt_font_size,
   --        R, G, B, 1, font_n)
end

-------------------------------------
-- Calls external script to pull number of unread Slack messages
-------------------------------------
function draw_slack()
   local x=250
   local y=10

   jimage(conky_parse("/home/${uid_name 1000}/wetch/slack-web.png"),
          30, 30, trans_x+x-25, trans_y+y)

   local undread=0
   unread=tonumber(conky_parse("${execi 5 ~/wetch/slack.sh}"))

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
function jprint(CR, str, x, y, fontSize, r, g, b, a, face)
   cairo_select_font_face(CR, "monospace", CAIRO_FONT_SLANT_NORMAL, face)
   cairo_set_font_size(CR, fontSize)
   cairo_set_source_rgba(CR, r, g, b, a)
   cairo_move_to(CR, x, y)
   cairo_show_text(CR, str)
   cairo_stroke(CR)
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
function circleFill(CR, x, y, rad, width, deg0, deg1, cmd, max, r, g, b, a)
   local value=conky_parse(cmd)
   local end_deg=value*(deg1-deg0)/max + deg0
   cairo_set_line_width(CR,width)
   cairo_set_line_cap(CR, CAIRO_LINE_CAP_SQUARE)
   cairo_set_source_rgba(CR,r,g,b,a)
   cairo_arc(CR,x,y,rad,(deg0-90)*(math.pi/180),(end_deg-90)*(math.pi/180))
   cairo_stroke(CR)
end

-------------------------------------
-- Draws image
-- @param path path to image
-- @param w image width in pixels
-- @param h image height in pixels
-- @param x Upper left corner x coordinate
-- @param y Upper left corner y coordinate
-------------------------------------
function jimage(CR, path, w, h, x, y)
   -- local image = imlib_load_image(path)
   -- imlib_context_set_image(image)

   -- local scaled=imlib_create_cropped_scaled_image(
   --    0, 0, imlib_image_get_width(),imlib_image_get_height(), w, h)

   -- imlib_context_set_image(scaled)
   -- imlib_render_image_on_drawable(x, y)
   -- imlib_free_image()

   -- if string.match(path, ".jpg") then
   --    pdf = PDFSurface("out.pdf", 1000, 1000)
   --    cr = Context(pdf)
   --    im = Image.open(path)
   --    buffer = StringIO.StringIO()
   --    cairo_save(im, buffer, format="PNG")
   --    cairo_seek(buffer, 0)
   --    cairo_save(CR)
   --    cairo_set_source_surface(CR, ImageSurface.create_from_png(buffer))
   --    cairo_paint(CR)
   -- end

   image = cairo_image_surface_create_from_png(path)
   cairo_translate(CR, x, y)
   cairo_scale(CR, w, h)
   cairo_set_source_surface(CR, image, 0, 0)
   cairo_paint(CR)
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
function jline(CR, x1, y1, x2, y2, w, r, g, b, a)
   cairo_set_line_width(CR, w)
   cairo_set_line_cap (CR, CAIRO_LINE_CAP_SQUARE)
   cairo_set_source_rgba(CR, r, g, b, a)
   cairo_move_to(CR, x1, y1)
   cairo_line_to(CR, x2, y2)
   cairo_stroke(CR)
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
      x0 = 500
      y0 = 100
      x1 = 800
      y1 = 400
      local pat=cairo_pattern_create_linear (x0, y0, x1, y1);
      cairo_pattern_add_color_stop_rgba (pat, 1, 0, 0, 0, 0);
      cairo_pattern_add_color_stop_rgba (pat, 0, 0, 0, 0, 1);
      cairo_rectangle (cr, y0, x0, x1-x0, y1-y0);
      cairo_set_source (cr, pat);
      cairo_fill (cr);
      cairo_pattern_destroy (pat);
      cairo_stroke (cr);
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
