local ui_get = ui.get
local get_prop = entity.get_prop
local get_local_player = entity.get_local_player
local get_entity_weapon = entity.get_player_weapon

local knife_lefthand = ui.new_checkbox("MISC", "Miscellaneous", "Knife Left Hand")

local function on_run_command(e)
	if ui_get(knife_lefthand) then
		local local_player = get_local_player()

		if local_player ~= nil then
			local weapon = get_entity_weapon(local_player)

			if entity.get_classname(weapon) == "CKnife" then
				client.exec("cl_righthand 0")
			else
				client.exec("cl_righthand 1")
			end
		end
	else
		client.exec("cl_righthand 1")
	end
end

client.set_event_callback("run_command", on_run_command)