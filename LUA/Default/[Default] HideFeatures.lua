local mask_ref = ui.reference("Skins", "Model options", "Mask changer")
local bullettracer_ref, col_ref = ui.reference("Visuals", "Effects", "Bullet tracers")
local unloadbutton_ref = ui.reference("MISC", "Settings", "Unload")


local hide_mask = ui.new_checkbox("LUA", "A", "Hide Mask changer")
local hide_bullettracer = ui.new_checkbox("LUA", "A", "Hide Bullet tracer")
local hide_unloadbutton = ui.new_checkbox("LUA", "A", "Hide Unload Button")

client.set_event_callback('predict_command', function()
    if ui.get(hide_mask) then
        ui.set_visible(mask_ref, false)
    else
        ui.set_visible(mask_ref, true)
    end
    if ui.get(hide_bullettracer) then
        ui.set_visible(bullettracer_ref, false)
        ui.set_visible(col_ref, false)
    else
        ui.set_visible(bullettracer_ref, true)
        ui.set_visible(col_ref, true)
    end
    if ui.get(hide_unloadbutton) then
        ui.set_visible(unloadbutton_ref, false)
    else
        ui.set_visible(unloadbutton_ref, true)
    end
end)