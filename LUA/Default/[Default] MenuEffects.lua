--local variables for API. Automatically generated by https://github.com/simpleavaster/gslua/blob/master/authors/sapphyrus/generate_api.lua 
local client_latency, client_log, client_draw_rectangle, client_draw_circle_outline, client_userid_to_entindex, client_draw_indicator, client_draw_gradient, client_set_event_callback, client_screen_size, client_eye_position = client.latency, client.log, client.draw_rectangle, client.draw_circle_outline, client.userid_to_entindex, client.draw_indicator, client.draw_gradient, client.set_event_callback, client.screen_size, client.eye_position 
local client_draw_circle, client_color_log, client_delay_call, client_draw_text, client_visible, client_exec, client_trace_line, client_set_cvar = client.draw_circle, client.color_log, client.delay_call, client.draw_text, client.visible, client.exec, client.trace_line, client.set_cvar 
local client_world_to_screen, client_draw_hitboxes, client_get_cvar, client_draw_line, client_camera_angles, client_draw_debug_text, client_random_int, client_random_float = client.world_to_screen, client.draw_hitboxes, client.get_cvar, client.draw_line, client.camera_angles, client.draw_debug_text, client.random_int, client.random_float 
local entity_get_local_player, entity_is_enemy, entity_get_player_name, entity_get_steam64, entity_get_bounding_box, entity_get_all, entity_set_prop, entity_get_player_weapon = entity.get_local_player, entity.is_enemy, entity.get_player_name, entity.get_steam64, entity.get_bounding_box, entity.get_all, entity.set_prop, entity.get_player_weapon 
local entity_hitbox_position, entity_get_prop, entity_get_players, entity_get_classname = entity.hitbox_position, entity.get_prop, entity.get_players, entity.get_classname 
local globals_realtime, globals_absoluteframetime, globals_tickcount, globals_curtime, globals_mapname, globals_tickinterval, globals_framecount, globals_frametime, globals_maxplayers = globals.realtime, globals.absoluteframetime, globals.tickcount, globals.curtime, globals.mapname, globals.tickinterval, globals.framecount, globals.frametime, globals.maxplayers 
local ui_new_slider, ui_new_combobox, ui_reference, ui_set_visible, ui_is_menu_open, ui_new_color_picker, ui_set_callback, ui_set, ui_new_checkbox, ui_new_hotkey, ui_new_button, ui_new_multiselect, ui_get = ui.new_slider, ui.new_combobox, ui.reference, ui.set_visible, ui.is_menu_open, ui.new_color_picker, ui.set_callback, ui.set, ui.new_checkbox, ui.new_hotkey, ui.new_button, ui.new_multiselect, ui.get 
local math_ceil, math_tan, math_log10, math_randomseed, math_cos, math_sinh, math_random, math_huge, math_pi, math_max, math_atan2, math_ldexp, math_floor, math_sqrt, math_deg, math_atan, math_fmod = math.ceil, math.tan, math.log10, math.randomseed, math.cos, math.sinh, math.random, math.huge, math.pi, math.max, math.atan2, math.ldexp, math.floor, math.sqrt, math.deg, math.atan, math.fmod 
local math_acos, math_pow, math_abs, math_min, math_sin, math_frexp, math_log, math_tanh, math_exp, math_modf, math_cosh, math_asin, math_rad = math.acos, math.pow, math.abs, math.min, math.sin, math.frexp, math.log, math.tanh, math.exp, math.modf, math.cosh, math.asin, math.rad 
local table_maxn, table_foreach, table_sort, table_remove, table_foreachi, table_move, table_getn, table_concat, table_insert = table.maxn, table.foreach, table.sort, table.remove, table.foreachi, table.move, table.getn, table.concat, table.insert 
local string_find, string_format, string_rep, string_gsub, string_len, string_gmatch, string_dump, string_match, string_reverse, string_byte, string_char, string_upper, string_lower, string_sub = string.find, string.format, string.rep, string.gsub, string.len, string.gmatch, string.dump, string.match, string.reverse, string.byte, string.char, string.upper, string.lower, string.sub 
--end of local variables 

local function distance(x1, y1, x2, y2)
	return math_sqrt((x2-x1)^2 + (y2-y1)^2)
end

local function hsv_to_rgb(h, s, v, a)
  local r, g, b

  local i = math_floor(h * 6);
  local f = h * 6 - i;
  local p = v * (1 - s);
  local q = v * (1 - f * s);
  local t = v * (1 - (1 - f) * s);

  i = i % 6

  if i == 0 then r, g, b = v, t, p
  elseif i == 1 then r, g, b = q, v, p
  elseif i == 2 then r, g, b = p, v, t
  elseif i == 3 then r, g, b = p, q, v
  elseif i == 4 then r, g, b = t, p, v
  elseif i == 5 then r, g, b = v, p, q
  end

  return r * 255, g * 255, b * 255, a * 255
end

local function contains(table, val)
	for i=1,#table do
		if table[i] == val then 
			return true
		end
	end
	return false
end

local menu_hotkey_reference = ui.reference("MISC", "Settings", "Menu key")
local menu_color_reference = ui.reference("MISC", "Settings", "Menu color")

local effects_reference = ui.new_multiselect("MISC", "Settings", "Menu effects", {"Lines", "Dots"})

local lines_label_reference = ui.new_label("MISC", "Settings", "Line Color")
local lines_color_reference = ui.new_color_picker("MISC", "Settings", "Line color", 100, 100, 100, 20)

--local gradient_label_reference = ui.new_label("MISC", "Settings", "Gradient Color")
--local gradient_color_reference = ui.new_color_picker("MISC", "Settings", "Gradient color", 16, 16, 16, 210)

local dots_label_reference = ui.new_label("MISC", "Settings", "Dots Color")
local dots_color_reference = ui.new_color_picker("MISC", "Settings", "Dots color", 255, 255, 255, 150)
local dots_connect_label_reference = ui.new_label("MISC", "Settings", "Dots Connect Color")
local dots_connect_color_reference = ui.new_color_picker("MISC", "Settings", "Dots connect color", 255, 255, 255, 50)

local function on_effects_change()
	local effects = ui_get(effects_reference)
	ui_set_visible(lines_label_reference, contains(effects, "Lines"))
	ui_set_visible(lines_color_reference, contains(effects, "Lines"))
	
	--ui_set_visible(gradient_label_reference, contains(effects, "Gradient"))
	--ui_set_visible(gradient_color_reference, contains(effects, "Gradient"))
	
	ui_set_visible(dots_label_reference, contains(effects, "Dots"))
	ui_set_visible(dots_color_reference, contains(effects, "Dots"))
	ui_set_visible(dots_connect_label_reference, contains(effects, "Dots"))
	ui_set_visible(dots_connect_color_reference, contains(effects, "Dots"))
end
on_effects_change()
ui_set_callback(effects_reference, on_effects_change)

local key_last_press = 0

local key_pressed_prev = false
local last_change = globals_realtime()-1

local x_dir, y_dir = "+", "+"
local x, y = 0, 0
local flags = "b"
local additional = 2
local tr, tg, tb = 149, 213, 72

local rainbow_progress = 0
local lines_progress = 0
local menu_open_prev = true

local dots = {}
local dot_size = 3
local function on_paint(ctx)
	local menu_open = ui_is_menu_open()
	local realtime = globals_realtime()
	if menu_open and not menu_open_prev then
		last_change = realtime
	end
	menu_open_prev = menu_open

	if not menu_open then
		return
	end

	local key_pressed = ui_get(menu_hotkey_reference)
	if key_pressed and not key_pressed_prev then
		key_last_press = realtime
	end
	key_pressed_prev = key_pressed

	local opacity_multiplier = menu_open and 1 or 0

	local menu_fade_time = 0.2

	if realtime - last_change < menu_fade_time then
		opacity_multiplier = (realtime - last_change) / menu_fade_time
	elseif realtime - key_last_press < menu_fade_time then
		opacity_multiplier = (realtime - key_last_press) / menu_fade_time
		opacity_multiplier = 1 - opacity_multiplier
	end

	if opacity_multiplier ~= 1 then
		--client.log(opacity_multiplier)
	end

	--draw effects
	if opacity_multiplier > 0 then
		local effects = ui_get(effects_reference)
		if #effects > 0 then
			local screen_width, screen_height = client_screen_size()

			--draw lines
			if contains(effects, "Lines") then
				local r, g, b, a = ui_get(lines_color_reference)
				a = a * opacity_multiplier
				for i=1, screen_width*1.6, 15 do
					local i = i + lines_progress*15
					client_draw_line(ctx, i, 0, i-screen_height, screen_height, r, g, b, a)
				end
				lines_progress = lines_progress + 0.1*5/80
				if lines_progress > 1 then
					lines_progress = 0
				end
			end

			--draw dots
			if contains(effects, "Dots") then
				local r, g, b, a = ui_get(dots_color_reference)
				a = a * opacity_multiplier
				local r_connect, g_connect, b_connect, a_connect = ui_get(dots_connect_color_reference)
				a_connect = a_connect * opacity_multiplier * 0.5
				local speed_multiplier = 20 / 100
				local dots_amount = 125
				local dots_connect_distance = 110
				local line_a = a/4
				while #dots > dots_amount do
					table_remove(dots, #dots)
				end
				while #dots < dots_amount do
					local x, y = client_random_int(-dots_connect_distance, screen_width+dots_connect_distance), client_random_int(-dots_connect_distance, screen_height+dots_connect_distance)
					local max = 12
					local min = 4

					local velocity_x
					if client_random_int(0, 1) == 1 then
						velocity_x = client_random_float(-max, -min)
					else
						velocity_x = client_random_float(min, max)
					end

					local velocity_y
					if client_random_int(0, 1) == 1 then
						velocity_y = client_random_float(-max, -min)
					else
						velocity_y = client_random_float(min, max)
					end

					local size = client_random_float(dot_size-1, dot_size+1)
					table_insert(dots, {x, y, velocity_x, velocity_y, size})
				end

				local dots_new = {}
				for i=1, #dots do
					local dot = dots[i]
					local x, y, velocity_x, velocity_y, size = dot[1], dot[2], dot[3], dot[4], dot[5]
					x = x + velocity_x*speed_multiplier*0.2
					y = y + velocity_y*speed_multiplier*0.2
					if x > -dots_connect_distance and x < screen_width+dots_connect_distance and y > -dots_connect_distance and y < screen_height+dots_connect_distance then
						table_insert(dots_new, {x, y, velocity_x, velocity_y, size})
					end
				end
				dots = dots_new

				for i=1, #dots do
					local dot = dots[i]
					local x, y, velocity_x, velocity_y, size = dot[1], dot[2], dot[3], dot[4], dot[5]
					for i2=1, #dots do
						local dot2 = dots[i2]
						local x2, y2 = dot2[1], dot2[2]
						local distance = distance(x, y, x2, y2)
						if distance <= dots_connect_distance then
							local a_connect_multiplier = 1
							if distance > dots_connect_distance * 0.7 then
								a_connect_multiplier = (dots_connect_distance - distance) / (dots_connect_distance * 0.3)
								--distance - dots_connect_distance / 
							end
							client_draw_line(ctx, x, y, x2, y2, r_connect, g_connect, b_connect, a_connect*a_connect_multiplier)
						end
					end
				end

				for i=1, #dots do
					local dot = dots[i]
					local x, y, velocity_x, velocity_y, size = dot[1], dot[2], dot[3], dot[4], dot[5]
					client_draw_circle(ctx, x, y, r, g, b, a, size, 0, 1, 1)
				end
			end

		end
	end
end

client_set_event_callback("paint", on_paint)