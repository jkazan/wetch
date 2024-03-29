require 'cairo'

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

   font_b=CAIRO_FONT_WEIGHT_BOLD
   fs = 14

   network()
   cairo_destroy(cr)
   cairo_surface_destroy(cs)
   cr=nil
end


function network()
   local x = 5
   local y = 3*fs

   local networks=split(conky_parse("${execi 1 ifconfig | grep -Eo '^(e|w)[[:alnum:]]+'}"))
   local net = ""
   local up_str = ""
   local down_str = ""
   local spacing = 1
   for i = 1,table.getn(networks) do
      local address = conky_parse("${addr " .. networks[i] .. "} ")
      if address ~= "No Address " then
          if networks[i]:sub(1, 1) == "w" then
             net_str = "${wireless_essid " .. networks[i] .. "}: " ..
                "${addr " .. networks[i] .. "} " ..
                "${wireless_link_qual_perc " .. networks[i] .. "}%"
          else
             net_str = networks[i] .. ": ${addr " .. networks[i] .. "}"
          end
          net = conky_parse(net_str)
          up_str = conky_parse("↑ ${upspeed " .. networks[i] .. "}")
          down_str = conky_parse("↓ ${downspeed " .. networks[i] .. "}")

          jprint(cr, net, x, y+fs*4*(spacing-1), fs, 0.48, 0.51, 0.67, 1)
          jprint(cr, up_str, x+60, y+fs*(4*(spacing-1)+1), fs, 0.48, 0.51, 0.67, 1)
          jprint(cr, down_str, x+60, y+fs*(4*(spacing-1)+2), fs, 0.48, 0.51, 0.67, 1)

          spacing = spacing+1
      end
   end
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
   cairo_select_font_face(CR, "Monospace", CAIRO_FONT_SLANT_NORMAL, face)
   cairo_set_font_size(CR, fontSize)
   cairo_set_source_rgba(CR, r, g, b, a)
   cairo_move_to(CR, x, y)
   cairo_show_text(CR, str)
   cairo_stroke(CR)
end

----------------------------------------------------------------------------------------
-- Splits string
-- @param inputstr String to split
----------------------------------------------------------------------------------------
function split(inputstr)
   if sep == nil then
      sep = "%s"
   end
   local t={}
   for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
   end

   return t
end
