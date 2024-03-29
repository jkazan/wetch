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

   font_n=CAIRO_FONT_WEIGHT_NORMAL
   font_b=CAIRO_FONT_WEIGHT_BOLD
   R=0
   G=0
   B=0
   badR=0.3
   badG=0
   badB=0
   fs = 14

   repo_path = os.getenv("WETCH_PATH")
   user = conky_parse("${execi 999999 cat PLACEHOLDER_WETCH_PATH/.user}")
   image = cairo_image_surface_create_from_png("/home/"..user.."/.cache/wetch/current.png")
   x = 0
   y = 2*fs

   spotify()
   cairo_destroy(cr)
   cairo_surface_destroy(cs)
   cairo_surface_destroy(image)
   cr=nil
end

function spotify()
   conky_parse("${execi 1 "..repo_path.."/src/spotify_metadata.sh}")
   -- Artist
   jprint(cr, conky_parse("${execi 1 "..repo_path.."/src/spotify_artist.sh}"),
          x+5, y+15, fs, 0.31, 0.54, 0, 1, font_n)

   -- Title
   jprint(cr, conky_parse("${execi 1 "..repo_path.."/src/spotify_title.sh}"),
          x+5, y+fs+20, fs, 0.31, 0.54, 0, 1, font_n)

   -- Artwork
   jimage(cr, 0.4, 0.4, x+5, y + 40, 0.8)
end

----------------------------------------------------------------------------------------
-- Prints string
-- @param CR Image width scale
-- @param str String to print
-- @param x Upper left corner x coordinate
-- @param y Upper left corner y coordinate
-- @param fontSize Font size
-- @param r Red
-- @param g Green
-- @param b Blue
-- @param a Alpha
-- @param face Cairo font face
----------------------------------------------------------------------------------------
function jprint(CR, str, x, y, fontSize, r, g, b, a, face)
   cairo_select_font_face(CR, "monospace", CAIRO_FONT_SLANT_NORMAL, face)
   cairo_set_font_size(CR, fontSize)
   cairo_set_source_rgba(CR, r, g, b, a)
   cairo_move_to(CR, x, y)
   cairo_show_text(CR, str)
   cairo_stroke(CR)
end

----------------------------------------------------------------------------------------
-- Draws image
-- @param CR Cairo reference
-- @param w Image width scale
-- @param h Image height scale
-- @param x Upper left corner x coordinate
-- @param y Upper left corner y coordinate
-- @param a Alpha
----------------------------------------------------------------------------------------
function jimage(CR, w, h, x, y, a)
   cairo_translate(CR, x, y)
   cairo_scale(CR, w, h)
   cairo_set_source_surface(CR, image, 0, 0)
   cairo_paint_with_alpha(cr, a)
end
