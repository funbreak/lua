local references = {
    DoubleTap = {ui.reference('RAGE', 'Aimbot', 'Double tap')},
    yaw_base = ui.reference('AA', 'Anti-aimbot angles', 'Yaw base'),
    yaw = {ui.reference('AA', 'Anti-aimbot angles', 'Yaw')},
}
local new = {
    enabled = ui.new_checkbox('AA', 'Fake lag', 'AA-Flick'),
    hotkey = ui.new_hotkey('AA', 'Fake lag', 'Hotkey', true),
    invert = ui.new_hotkey('AA', 'Fake lag', 'Inverter'),
    range = ui.new_slider('AA', 'Fake lag', 'Flick Range', 1, 180, 90, true),
    invertrange = ui.new_slider('AA', 'Fake lag', 'Flick Inverted Range', -1, -180, -90, true)
}

ui.set_visible(new.hotkey, false)
ui.set_visible(new.invert, false)
local on_ui_callback = function()
    local enabled = ui.get(new.enabled)
    ui.set_visible(new.hotkey, enabled)
    ui.set_visible(new.invert, enabled)
end
ui.set_callback(new.enabled, on_ui_callback)

local on_paint = function()
    local tickcount = globals.tickcount() % 17
    local x, y = client.screen_size()
    local center = {x / 2, y / 2}
    local yaw_slider = ui.get(references.yaw[2])
    local is_it_on = ui.get(new.hotkey)
    local doubletap = ui.get(references.DoubleTap[1]) and ui.get(references.DoubleTap[2])
    local flickrange = ui.get(new.range)
    local flickinvertrange = ui.get(new.invertrange)

    if is_it_on and doubletap then
        if not is_it_on then
            ui.set(references.yaw[2], '0')
        end

        ui.set(references.yaw[1], '180')
        ui.set(references.yaw[2], '0')

        if tickcount == 15 or tickcount == 17 and doubletap and is_it_on then
            if ui.get(new.invert) then
                ui.set(references.yaw[2], flickinvertrange)
            end

            if not ui.get(new.invert) then
                ui.set(references.yaw[2], flickrange)
            end

            client.exec('-use')
        end
    end
end

client.set_event_callback('paint', on_paint)