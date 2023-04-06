local no_sleeve = ui.new_checkbox("visuals", "other esp", "No Sleeve")
client.set_event_callback("paint", function()
    local sleeve = materialsystem.find_materials("sleeve")
    for i=#sleeve, 1, -1 do
        if ui.get(no_sleeve) then
            sleeve[i]:set_material_var_flag(2, true)
        else
            sleeve[i]:set_material_var_flag(2, false)
        end
    end
end)


-------- This only applies noSleeve when connecting to a map ----------- 

--local no_sleeve = ui.new_checkbox("visuals", "other esp", "No Sleeve")

--local function removeSleeve()
    --local sleeve = materialsystem.find_materials("sleeve")
    --for i=#sleeve, 1, -1 do
        --if ui.get(no_sleeve) then
            --sleeve[i]:set_material_var_flag(2, true)
        --else
            --sleeve[i]:set_material_var_flag(2, false)
        --end
    --end
--end

--client.set_event_callback("player_connect_full", function(e)
    --if (client.userid_to_entindex(e.userid) == entity.get_local_player()) then
        --removeSleeve()
    --end
--end)


