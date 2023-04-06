local gif_decoder = require "../../gamesense/gif_decoder"

local gif1 = gif_decoder.load_gif(readfile("../../gif1.gif") or error("Your Waifu is trash."))
local start_time = globals.realtime()

client.set_event_callback("paint_ui", function()
	if ui.is_menu_open() then
		local mx, my = ui.menu_position()
		local mw, mh = ui.menu_size()
        
		gif1:draw(globals.realtime()-start_time, mx+mw-gif1.width, my-gif1.height, gif1.width, gif1.height, 255, 255, 255, 255)
	end
end)
