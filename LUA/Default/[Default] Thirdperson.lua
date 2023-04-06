local ui_get = ui.get
local ui_set = ui.set
local ui_ref = ui.reference
local ui_set_callback = ui.set_callback
local client_exec = client.exec

local new_button = ui.new_checkbox("LUA", "B", "Disable collision")
local new_slider = ui.new_slider("LUA", "B", "Thirdperson delta", 0, 150, 150)

ui_set_callback(new_slider, function()
    slider = ui_get(new_slider)
    client_exec("cam_idealdist ", slider)
end)

ui_set_callback(new_button, function()
    local boxValue = ui_get(new_button)
    if boxValue then
        client_exec("cam_collision 0")
    else
        client_exec("cam_collision 1")
    end
end)