local remove_3dsky_ref = ui.new_checkbox('LUA', 'A', 'Remove 3D skybox')
local r_3dsky = cvar.r_3dsky

local function on_remove_3dsky_toggle(ref)
    r_3dsky:set_raw_int(ui.get(ref) and 0 or tonumber(r_3dsky:get_string()))
end

on_remove_3dsky_toggle(remove_3dsky_ref)
ui.set_callback(remove_3dsky_ref, on_remove_3dsky_toggle)