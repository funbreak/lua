local hpbar = {
    customhealthbars = ui.new_combobox("VISUALS","Player ESP", "Custom healthbar", "Off", "Gamesense", "Fade", "Duo"),
    colorpickerlabel = ui.new_label("VISUALS", "Player ESP", "Color 1"),
    colorpicker = ui.new_color_picker("VISUALS", "Player ESP", "Color picker", 40, 200, 64, 255),
    colorpickerlabel2 = ui.new_label("VISUALS", "Player ESP", "Color 2"),
    colorpicker2 = ui.new_color_picker("VISUALS", "Player ESP", "Color picker2", 40, 155, 200, 255),
}

local healthbar_ref = ui.reference("VISUALS", "Player ESP", 'Health bar')
    
ui.set_visible(hpbar.colorpicker, false)
ui.set_visible(hpbar.colorpickerlabel, false)
ui.set_visible(hpbar.colorpicker2, false)
ui.set_visible(hpbar.colorpickerlabel2, false)

client.set_event_callback("paint", function()
    if ui.get(hpbar.customhealthbars) ~= "Off" then
        ui.set(healthbar_ref, false)
        ui.set_visible(hpbar.colorpicker, true)
        ui.set_visible(hpbar.colorpickerlabel, true)
        ui.set_visible(hpbar.colorpicker2, true)
        ui.set_visible(hpbar.colorpickerlabel2, true)

        r, g, b, a = ui.get(hpbar.colorpicker)
        r2, g2, b2, a2 = ui.get(hpbar.colorpicker2)
        local enemy_players = entity.get_players(not enemies_only)

        for i=1,#enemy_players do	
            local e = enemy_players[i]
            local x1, y1, x2, y2, a = entity.get_bounding_box(e)
            if x1 ~= nil and y1 ~= nil then
                local hp = entity.get_prop(e, "m_iHealth")
                local height = y2 - y1 
                local width = x2 - x1
                local leftside = x1 - (width/12)
                if hp ~= nil then
                    if ui.get(hpbar.customhealthbars) == "Off" then 
                        return 
                    else
                        renderer.rectangle(leftside-1, y1-1, 4, height+1, 20, 20, 20, 220)
                        if ui.get(hpbar.customhealthbars) == "Gamesense" then
                            renderer.rectangle(leftside, y2-(height*hp/100), 2, height*hp/100-1, r, g, b, 255)
                        elseif ui.get(hpbar.customhealthbars) == "Fade" then
                            renderer.gradient(leftside, y2-(height*hp/100), 2, height*hp/100-1, r, g, b, 40, r, g, b, 255, false)
                        elseif ui.get(hpbar.customhealthbars) == "Duo" then
                            renderer.gradient(leftside, y2-(height*hp/100), 2, height*hp/100-1, r, g, b, 255, r2, g2, b2, 255, false)
                        end
    
                        if hp < 100 then
                            renderer.text(leftside, y2-(height*hp/100), 255, 255, 255, 255, "-cd", 0, hp )
                        end
                    end
                end
            end
        end
    else
        ui.set_visible(hpbar.colorpicker, false)
        ui.set_visible(hpbar.colorpickerlabel, false)
        ui.set_visible(hpbar.colorpicker2, false)
        ui.set_visible(hpbar.colorpickerlabel2, false)
    end
end)