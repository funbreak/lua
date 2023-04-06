
client.set_event_callback('setup_command', function (cmd)
    if ui.is_menu_open() then 
        cmd.in_attack = false
        cmd.in_attack2 = false
    end
end)