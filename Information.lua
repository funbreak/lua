local globals_realtime, global_absoluteframetime = globals.realtime, globals.absoluteframetime
local ui_get, ui_set, ui_new_checkbox, ui_new_slider, ui_new_combobox, ui_new_listbox, ui_new_label, ui_set_visible, ui_reference, ui_new_hotkey, ui_new_string, ui_new_textbox = ui.get, ui.set, ui.new_checkbox, ui.new_slider, ui.new_combobox, ui.new_listbox, ui.new_label, ui.set_visible, ui.reference, ui.new_hotkey, ui.new_string, ui.new_textbox
local ui_menu_position, ui_new_multiselect, ui_menu_size, ui_is_menu_open, ui_mouse_position, ui_set_callback = ui.menu_position, ui.new_multiselect, ui.menu_size, ui.is_menu_open, ui.mouse_position, ui.set_callback
local client_screen_size, client_set_event_callback = client.screen_size, client.set_event_callback
local renderer_rectangle, renderer_gradient, renderer_text, renderer_measure = renderer.rectangle, renderer.gradient, renderer.text, renderer.measure_text
local min, max, floor, abs = math.min, math.max, math.floor, math.abs

local toggle = ui_new_checkbox("LUA", "A", "Menu Component")
local configBox = ui_new_combobox("LUA", "A", "Config Name", "Default", "Legit I", "Legit II", "Semi-Rage I",  "Semi-Rage II", "Rage I", "Rage II")

--- references ---
local menu_hotkey_reference = ui_reference("MISC", "Settings", "Menu key")
local dpi_scale = ui_reference("MISC", "Settings", "DPI scale")
local menu_col = ui_reference("MISC", "Settings", "Menu color")

--main variables
local key_pressed_prev = false
local menu_open = true
local last_change = globals_realtime()-1
local FRAME_SAMPLE_COUNT = 64
local FRAME_SAMPLE_TIME = 0.5
local frametimes = {}
local frametimes_index = 0
local variance = 0
local avg_fps = 0
local localname = panorama.open().MyPersonaAPI.GetName()

local function init()
	local ft = global_absoluteframetime()
	for i = FRAME_SAMPLE_COUNT-1, 0, -1 do
		frametimes[i] = ft
	end
end

init()

local function tointeger(n)
	return floor(n + 0.5)
end

local function accumulate_fps()
	local ft = global_absoluteframetime()
	if ft > 0 then
		frametimes[frametimes_index] = ft
		frametimes_index = frametimes_index + 1
		if frametimes_index >= FRAME_SAMPLE_COUNT then
			frametimes_index = 0
		end
	end

	local accum = 0
	local accum_count = 0
	local idx = frametimes_index
	local prev_ft = nil
	variance = 0
	for i = 0, FRAME_SAMPLE_COUNT-1 do
		idx = idx - 1
		if idx < 0 then
			idx = FRAME_SAMPLE_COUNT-1
		end
		ft = frametimes[idx]
		if ft == 0 then
			break
		end
		accum = accum + ft
		accum_count = accum_count + 1
		if prev_ft then
			variance = max(variance, abs(ft - prev_ft))
		end
		prev_ft = ft
		if accum >= FRAME_SAMPLE_TIME then
			break
		end
	end
	if accum_count == 0 then
		return 0
	end
	accum = accum / accum_count

	local fps = tointeger(1 / accum)
	if abs(fps - avg_fps) > 5 then
		avg_fps = fps
	else
		fps = avg_fps
	end
	return fps
end

local function getLabelLength(formatlabel, label)
	local labellength = renderer_measure(formatlabel, label)
	
	return labellength
end

local function getTextLength(formattext, text)
	local textlength = renderer_measure(formattext, text)
	
	return textlength
end

local function text(xPos, yPos, r, g, b, a, formatLabel, label, formatText, text)
	local labelLength = getLabelLength(formatLabel, label)
	local textLength = getTextLength(formatText, text)
	local padding = 10
	local spacing = 8

	renderer_text(xPos, yPos, 255, 255, 255, a, formatLabel, 0, label .. ":")
	renderer_text(xPos + labelLength + spacing, yPos, r, g, b, a, formatText, 0, text)

	return labelLength + textLength + padding + spacing
end

local function menu(xpos, ypos, width, height, alpha)
	local menu_r, menu_g, menu_b, menu_a = ui_get(menu_col)
	local margin = 10
	local ping = tointeger(min(1000, client.real_latency()*1000))
	local timeh, timem, times = client.system_time()
	local textPosX, textPosY = xpos + margin, ypos + 9

	--Menu rectangle
    renderer_rectangle(xpos - 6, ypos - 6, width + 12, height + 12, 12, 12, 12, alpha)
    renderer_rectangle(xpos - 5, ypos - 5, width + 10, height + 10, 60, 60, 60, alpha)
    renderer_rectangle(xpos - 4, ypos - 4, width + 8, height + 8, 40, 40, 40, alpha)
    renderer_rectangle(xpos - 1, ypos - 1, width + 2, height + 2, 60, 60, 60, alpha)
    renderer_rectangle(xpos, ypos, width, height, 23, 23, 23, alpha)

	--Menu Information Text
	-- make loop to generate all of these
	local username = text(textPosX, textPosY, menu_r, menu_g, menu_b, alpha, "bd", "User", "d", localname)
	local framerate = text(textPosX + username, textPosY, menu_r, menu_g, menu_b, alpha, "bd", "Framerate", "d", accumulate_fps() .. "fps")
	local latency = text(textPosX + username + framerate, textPosY, menu_r, menu_g, menu_b, alpha, "bd", "Latency", "d", ping .. "ms")
	local time = text(textPosX + username + framerate + latency, textPosY, menu_r, menu_g, menu_b, alpha, "bd", "Time", "d", timeh .. ":" .. timem .. ":" .. times)

	--Config Information Text
	local configText = getLabelLength("bf", "Config Loaded:") + getTextLength("d", ui_get(configBox))
	text(textPosX + width - configText - 30, textPosY, menu_r, menu_g, menu_b, alpha, "bd", "Config Loaded", "d", ui_get(configBox))
end

client_set_event_callback("paint_ui", function()
	local menu_pos_x, menu_pos_y = ui_menu_position()          
	local menu_pos_w, menu_pos_h = ui_menu_size()
	local x_i, y_i

	if ui_get(toggle) then
		x_i, y_i = menu_pos_x + 6, menu_pos_y + menu_pos_h + 12
	else
		return
	end
	local key_pressed = ui_get(menu_hotkey_reference)
	if key_pressed and not key_pressed_prev then
		menu_open = not menu_open
		last_change = globals_realtime()
	end
	key_pressed_prev = key_pressed
	local opacity_multiplier = 0
	if menu_open then
		opacity_multiplier = 1
	end
	if globals_realtime() - last_change < 0.15 then
		opacity_multiplier = (globals_realtime() - last_change) / 0.15
		if not menu_open then
			opacity_multiplier = 1 - opacity_multiplier
		end
	end

	menu(x_i, y_i, menu_pos_w - 12, 30, 255*opacity_multiplier)
end)