local clantagspammerold = ui.reference("MISC", "Miscellaneous", 'Clan tag spammer')
local clantagspammernew = ui.new_checkbox("MISC", "Miscellaneous", 'Clan tag spammer')
local clantagspammerhotkey = ui.new_hotkey("MISC", "Miscellaneous", 'Clan tag spammer', true)


local is_pressed = false
ui.set_visible(clantagspammerold, true)

client.set_event_callback('predict_command', function()
    if clantagspammernew then
        ui.set(clantagspammerold, true)
    else
        ui.set(clantagspammerold, false)
    end

    local hotkey_state = ui.get(clantagspammerhotkey)
    if hotkey_state then
        if not is_pressed then
            ui.set(clantagspammernew, true)
            is_pressed = true
        end
    else
        if is_pressed then
            ui.set(clantagspammernew, false)
            is_pressed = false
        end
    end
end)