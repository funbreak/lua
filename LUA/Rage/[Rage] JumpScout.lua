-- P Jumpscout LUA pasted by funbreak :)
--
-- Library for Weapon Data (needs to be subscribed)
-- https://gamesense.pub/forums/viewtopic.php?id=18807
--
-- Sources used for this: 
-- https://gamesense.pub/forums/viewtopic.php?id=3357 Jump Hitchance
-- https://gamesense.pub/forums/viewtopic.php?id=19239 Disable Airstrafe

local ui_get = ui.get
local ui_set = ui.set
local ui_set_visible = ui.set_visible
local bit_band = bit.band

local csgo_weapons = require "gamesense/csgo_weapons"
local air_strafe = ui.reference("Misc", "Movement", "Air strafe")
local hitchance = ui.reference("RAGE", "Aimbot", "Minimum hit chance")
local jumpscout = ui.new_checkbox("RAGE", "Other", "Jumpscout")
local jumpscouthc = ui.new_slider("RAGE", "Other", "Jumpscout hitchance", 0, 100, 0, true, "%")

local backuphitchance = nil
ui_set_visible(jumpscouthc, false)

client.set_event_callback("setup_command", function(c)
    if ui_get(jumpscout) then
        ui_set_visible(jumpscouthc, true)

        local vel_x, vel_y = entity.get_prop(entity.get_local_player(), "m_vecVelocity")

        local local_player = entity.get_local_player()
        if local_player == nil then return end

        local weapon_ent = entity.get_player_weapon(local_player)
        if weapon_ent == nil then return end

        local weapon_idx = entity.get_prop(weapon_ent, "m_iItemDefinitionIndex")
        if weapon_idx == nil then return end
        weapon_idx = bit.band(weapon_idx, 0xFFFF)

        local weapon = csgo_weapons[weapon_idx]
        if weapon == nil then return end
	
	    local flags = entity.get_prop(local_player, "m_fFlags");
	    if flags == nil then
		    return
	    end
	
	    if not backuphitchance then
		    backuphitchance = ui_get(hitchance)
	    end

        local onground = bit_band(flags, 1);
        
	    if onground == 0 and vel_x <= 5 and vel_y <= 5 and vel_x >= -5 and vel_y >= -5 then
		    local jumphc = ui_get(jumpscouthc);
            ui_set(hitchance, jumphc);
        else
            ui_set(hitchance, backuphitchance)
	    end

        if weapon.name == "SSG 08" then
            local vel = math.sqrt(vel_x^2 + vel_y^2)
            ui_set(air_strafe, not (c.in_jump and (vel < 10)))
        else
            ui_set(air_strafe, true)
        end
    else
        ui_set_visible(jumpscouthc, false)
    end
end)