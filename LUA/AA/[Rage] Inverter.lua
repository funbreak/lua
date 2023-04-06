local ui_checkbox = ui.new_checkbox("AA", "Anti-aimbot angles", "Inverter")
local ui_keybind = ui.new_hotkey("AA", "Anti-aimbot angles", "Desync jitter", true)
local _, ui_Yaw = ui.reference("AA", "Anti-aimbot angles", "Yaw")
local _, ui_YawJitter= ui.reference("AA", "Anti-aimbot angles", "Yaw jitter")
local _, ui_byaw = ui.reference("AA", "Anti-aimbot angles", "Body yaw")
local key_status = false

client.set_event_callback("paint", function(c)
    if ui.get(ui_checkbox) then
        if ui.get(ui_keybind) ~= key_status then
            ui.set(ui_Yaw, ui.get(ui_Yaw)*-1)
            ui.set(ui_YawJitter, ui.get(ui_YawJitter)*-1)
            ui.set(ui_byaw, ui.get(ui_byaw)*-1)
        end
        
        key_status = ui.get(ui_keybind)
    end
end)