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
   fs = 15

   image = cairo_image_surface_create_from_png("/home/johannek/.cache/wetch/current.png")
   height = conky_parse("${execi 1 xrandr | grep -Eo 'primary [[:alnum:]]+' | grep -Eo '[[:digit:]]+$' }")
   x = 0
   y = 2*fs + tonumber(height)-1080

   spotify()
   cairo_destroy(cr)
   cairo_surface_destroy(cs)
   cairo_surface_destroy(image)
   cr=nil
end


function spotify()

   -- Artist
   jprint(cr, conky_parse("${exec ~/wetch/spotify-artist.sh}"),
          x+5, y, fs, 0.31, 0.54, 0, 1, CAIRO_FONT_WEIGHT_BOLD)

   -- Title
   jprint(cr, conky_parse("${exec ~/wetch/spotify-title.sh}"),
          x+5, y+fs, fs, 0.31, 0.54, 0, 1, CAIRO_FONT_WEIGHT_BOLD)

   -- Artwork
   conky_parse("${exec ~/wetch/spotify-cover.sh}")
   jimage(cr, 0.93, 0.93, x, y + 20, 0.5)
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
function jimage(CR, w, h, x, y, a)
   cairo_translate(CR, x, y)
   cairo_scale(CR, w, h)
   cairo_set_source_surface(CR, image, 0, 0)
   cairo_paint_with_alpha(cr, a)
end
