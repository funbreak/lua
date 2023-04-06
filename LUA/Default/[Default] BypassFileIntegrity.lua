local ffi = require"ffi"
local client_delay_call, ui_get = client.delay_call, ui.get

local enabled = ui.new_checkbox("MISC", "Miscellaneous", "Load files bypass")
local sv_pure_bypass = ui.reference("MISC", "Miscellaneous", "Disable sv_pure")

local file_system = ffi.cast("int*", client.create_interface("filesystem_stdio.dll", "VFileSystem017") or error("VFileSystem017 not found"))

ui.set_callback(enabled, function()
    if ui.get(enabled) then
        ui.set(sv_pure_bypass, true)
        set_files_is_checked_porperly()
    end
end)

function set_files_is_checked_porperly()
    if ui_get(enabled) then
        file_system[56] = 1
        client_delay_call(0.04, set_files_is_checked_porperly )
    end
end