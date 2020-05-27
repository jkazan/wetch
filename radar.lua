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
   -- map = cairo_create(cs)

   font_n=CAIRO_FONT_WEIGHT_NORMAL
   font_b=CAIRO_FONT_WEIGHT_BOLD
   R=0
   G=0
   B=0
   badR=0.3
   badG=0
   badB=0
   fs = 15

   img_radar = cairo_image_surface_create_from_png("/home/johannek/.cache/wetch/radar.png")
   -- img_map = cairo_image_surface_create_from_png("/home/johannek/wetch/test.png")
   -- jimage(map, img_radar, 3, 3, x, 50, 0.5)


   radar()
   cairo_destroy(cr)
   -- cairo_destroy(map)
   cairo_surface_destroy(cs)
   cairo_surface_destroy(img_radar)
   cr=nil
end


function radar()
   local x = 0
   local y = 2*fs

   conky_parse("${execi 300 python ~/wetch/radar.py}")
   jimage(cr, img_radar, 0.6, 0.6, x, 50, 0.5)
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
-- @param w image width scale
-- @param h image height scale
-- @param x Upper left corner x coordinate
-- @param y Upper left corner y coordinate
-- @param a alpha
-------------------------------------
function jimage(CR, img, w, h, x, y, a)
   cairo_translate(CR, x, y)
   cairo_scale(CR, w, h)
   cairo_set_source_surface(CR, img, 0, 0)
   cairo_paint_with_alpha(cr, a)
end
