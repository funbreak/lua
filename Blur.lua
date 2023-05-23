local menublur = ui.new_checkbox("LUA", "A", 'Menu Blur')

client.set_event_callback('paint', function()
    if ui.get(menublur) and ui.is_menu_open() then
        local screenx, screeny = client.screen_size()
        renderer.blur(0, 0, screenx, screeny, 1, 1)
    end
end)

