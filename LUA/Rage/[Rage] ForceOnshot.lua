local hotkey = ui.new_hotkey('rage', 'other', 'Force on shot')
local indicator = ui.new_checkbox('rage', 'other', 'Force on shot indicator')
local multipoint = ui.reference('rage', 'aimbot', 'multi-point')
local target_hitbox = ui.reference('rage', 'aimbot', 'target hitbox')

local ui_get, ui_set = ui.get, ui.set
local globals_curtime, globals_tickinterval = globals.curtime, globals.tickinterval
local entity_get_player_weapon, entity_get_players, entity_get_prop = entity.get_player_weapon, entity.get_players, entity.get_prop
local plist_set = plist.set
local client_screen_size = client.screen_size
local renderer_text = renderer.text
local math_floor = math.floor

local is_pressed = false
local cached1 = {}
local cached2 = {}

client.set_event_callback('predict_command', function()
    local hotkey_state = ui_get(hotkey)
    if hotkey_state then
        if not is_pressed then
            cached_multipoint = ui_get(multipoint)
            cached_target_hitbox = ui_get(target_hitbox)

            ui_set(multipoint, {'head'})
            ui_set(target_hitbox, {'head'})
        end
        is_pressed = true
    else
        if is_pressed then
            ui_set(multipoint, cached_multipoint)
            ui_set(target_hitbox, cached_target_hitbox)
        end
        is_pressed = false
    end

    local curtime = globals_curtime()
    local tickinterval = globals_tickinterval()

    local max_backtrackable_ticks = math_floor(0.2 / tickinterval)

    local players = entity_get_players(true)
    for _, player in pairs(players) do
        local player_weapon = entity_get_player_weapon(player)
        local last_shot_time = entity_get_prop(player_weapon, 'm_fLastShotTime')
        if last_shot_time then

            local time_difference = curtime - last_shot_time
            local ticks_since_last_shot = time_difference / tickinterval

            plist_set(player, 'add to whitelist', ticks_since_last_shot > max_backtrackable_ticks and hotkey_state)
        end
    end
end)

client.set_event_callback('paint', function()
    if ui_get(indicator) and ui_get(hotkey) then
        local w, h = client_screen_size()
        local center_x, center_y = w / 2, h / 2

        renderer_text(center_x, center_y + 40, 255, 255, 255, 220, "c", 0, "Force on shot")
    end
end)