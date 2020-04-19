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
   R=0
   G=0
   B=0
   badR=0.3
   badG=0
   badB=0
   fs = 20

   draw_load()
   cairo_destroy(cr)
   cairo_surface_destroy(cs)
   cr=nil
end

function draw_load()
   local x=20

   local thick = 15

   -- cpu
   local y0=210
   local y = y0
   local cpu_usage=tonumber(conky_parse("${cpu}"))
   local c=get_colors_gt(cpu_usage, 80)
   local r = 80

   circleFill(cr, x+fs*3, y+r-fs/4, r, thick, 0, 240, "100", 100, c[1], c[2], c[3], 0.2)
   circleFill(cr, x+fs*3, y+r-fs/4, r, thick, 0, 240, cpu_usage, 100, c[1], c[2], c[3], 0.5)
   jprint(cr, "cpu", x, y, fs, c[1], c[2], c[3], 1, font_n)

   local start=40
   local length=190/4 - 5
   local stop=30

   for i=0, 3, 1 do
      local cpuinner="${cpu cpu" .. i+1 .. "}"
      circleFill(cr, x+fs*3, y+r-fs/4, r+23, 10,
                 start+i*length,
                 start+i*length+stop,
                 "100", 100, c[1], c[2], c[3], 0.2)
      circleFill(cr, x+fs*3, y+r-fs/4, r+23, 10,
                 start+i*length,
                 start+i*length+stop,
                 cpuinner, 100, c[1], c[2], c[3], 0.5)

      local cpuouter="${cpu cpu" .. i+5 .. "}"
      circleFill(cr, x+fs*3, y+r-fs/4, r+40, 10,
                 start+i*length,
                 start+i*length+stop,
                 "100", 100, c[1], c[2], c[3], 0.2)
      circleFill(cr, x+fs*3, y+r-fs/4, r+40, 10,
                 start+i*length,
                 start+i*length+stop,
                 cpuouter, 100, c[1], c[2], c[3], 0.5)
   end

   -- ram
   local r = 60
   local y = y0 + 80 - r
   local ram_usage=tonumber(conky_parse("${memperc}"))
   local c=get_colors_gt(ram_usage, 80)


   circleFill(cr, x+fs*3, y+r-fs/4, r, thick, 0, 240, "100", 100, c[1], c[2], c[3], 0.2)
   circleFill(cr, x+fs*3, y+r-fs/4, r, thick, 0, 240, ram_usage, 100, c[1], c[2], c[3], 0.5)
   jprint(cr, "ram", x, y, fs, c[1], c[2], c[3], 1, font_n)

   -- root
   local r = 40
   local y = y0 + 80 - r
   local root_usage=tonumber(conky_parse("${fs_used_perc}"))
   local c=get_colors_gt(root_usage, 80)

   circleFill(cr, x+fs*3, y+r-fs/4, r, thick, 0, 240, "100", 100, c[1], c[2], c[3], 0.2)
   circleFill(cr, x+fs*3, y+r-fs/4, r, thick, 0, 240, root_usage, 100, c[1], c[2], c[3], 0.5)
   jprint(cr, "root", x-11, y, fs, c[1], c[2], c[3], 1, font_n)


   -- swap
   local r = 20
   local y = y0 + 80 - r
   local swap_usage = tonumber(conky_parse("${swapperc}"))
   local c = get_colors_gt(swap_usage, 80)

   circleFill(cr, x+fs*3, y+r-fs/4, r, thick, 0, 240, "100", 100, c[1], c[2], c[3], 0.2)
   circleFill(cr, x+fs*3, y+r-fs/4, r, thick, 0, 240, swap_usage, 100, c[1], c[2], c[3], 0.5)
   jprint(cr, "swap", x-11, y, fs, c[1], c[2], c[3], 1, font_n)
end

-------------------------------------
function jprint(CR, str, x, y, fontSize, r, g, b, a, face)
   cairo_select_font_face(CR, "Monospace", CAIRO_FONT_SLANT_NORMAL, face)
   cairo_set_font_size(CR, fontSize)
   cairo_set_source_rgba(CR, r, g, b, a)
   cairo_move_to(CR, x, y)
   cairo_show_text(CR, str)
   cairo_stroke(CR)
end

-------------------------------------
-- Draws image
-- @param path path to image
-- @param w image width scale
-- @param h image height scale
-- @param x Upper left corner x coordinate
-- @param y Upper left corner y coordinate
-- @param a alpha
-------------------------------------
function jimage(CR, path, w, h, x, y, a)
   image = cairo_image_surface_create_from_png(path)
   cairo_translate(CR, x, y)
   cairo_scale(CR, w, h)
   cairo_set_source_surface(CR, image, 0, 0)
   cairo_paint_with_alpha(cr, a)
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
