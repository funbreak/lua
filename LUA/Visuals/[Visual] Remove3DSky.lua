-- Cache common functions
local ui_get = ui.get

-- Constants and variables
local remove_3dsky_ref = ui.new_checkbox('Visuals', 'Effects', 'Remove 3D skybox')
local r_3dsky = cvar.r_3dsky

-- Callback functions
local function on_remove_3dsky_toggle(ref)
    r_3dsky:set_raw_int(ui_get(ref) and 0 or tonumber(r_3dsky:get_string()))
end

-- Initilization code
on_remove_3dsky_toggle(remove_3dsky_ref)
ui.set_callback(remove_3dsky_ref, on_remove_3dsky_toggle)