local FaggotFlag = ui.new_checkbox("Visuals", "Other ESP", "Faggot flag")
local r,g,b = 250,100,100

client.register_esp_flag("", r,g,b, function(ent)

    if plist.get(ent, "High priority") then
    if entity.is_dormant(ent) then 
        r,g,b = 1,1,1
    end
    if ui.get(FaggotFlag) then
        return true, "FAGGOT"
    end
    else
        return false 
    end
end)

--