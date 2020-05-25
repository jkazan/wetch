require 'cairo'

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
   for i = 1,len(networks) do
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

      jprint(cr, net, x, y+fs*4*(i-1), fs, 0.48, 0.51, 0.67, 1)
      jprint(cr, up_str, x+60, y+fs*(4*(i-1)+1), fs, 0.48, 0.51, 0.67, 1)
      jprint(cr, down_str, x+60, y+fs*(4*(i-1)+2), fs, 0.48, 0.51, 0.67, 1)
   end
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

function split (inputstr, sep)
   if sep == nil then
      sep = "%s"
   end
   local t={}
   for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
   end
   return t
end

function len(T)
   local count = 0
   for _ in pairs(T) do count = count + 1 end
   return count
end
