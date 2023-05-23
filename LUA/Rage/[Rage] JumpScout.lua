-- P Jumpscout LUA pasted by funbreak :)
--
-- Library for Weapon Data (needs to be subscribed)
-- https://gamesense.pub/forums/viewtopic.php?id=18807
--
-- Sources used for this: 
-- https://gamesense.pub/forums/viewtopic.php?id=3357 Jump Hitchance
-- https://gamesense.pub/forums/viewtopic.php?id=19239 Disable Airstrafe

local ui_get, ui_set, ui_set_visible, renderer_indicator = ui.get, ui.set, ui.set_visible, renderer.indicator
local bit_band = bit.band
local csgo_weapons = require "gamesense/csgo_weapons"


local air_strafe = ui.reference("Misc", "Movement", "Air strafe")
local hitchance = ui.reference("RAGE", "Aimbot", "Minimum hit chance")
local jumpscout = ui.new_checkbox("LUA", "A", "Jumpscout")
local jumpscouthc = ui.new_slider("LUA", "A", "Jumpscout hitchance", 0, 100, 0, true, "%")

local backuphitchance = ui_get(hitchance)
local hitchanceSet = false

client.set_event_callback("setup_command", function(c)
    if ui_get(jumpscout) then
        ui_set_visible(jumpscouthc, true)

        local vel_x, vel_y = entity.get_prop(entity.get_local_player(), "m_vecVelocity")
        local local_player = entity.get_local_player()
        local flags = entity.get_prop(local_player, "m_fFlags");
        local weapon_ent = entity.get_player_weapon(local_player)
        local weapon_idx = entity.get_prop(weapon_ent, "m_iItemDefinitionIndex")
        local weapon = csgo_weapons[weapon_idx]

        local function velocityCheck()
            if vel_x <= 150 and vel_y <= 150 and vel_x >= -150 and vel_y >= -150 then
                return true
            end
        end

        if local_player == nil then return end
        if weapon_ent == nil then return end
        if weapon_idx == nil then return end
        weapon_idx = bit_band(weapon_idx, 0xFFFF)
        if weapon == nil then return end
	    if flags == nil then return end

        local onground = bit_band(flags, 1);
        
	    if weapon.name == "SSG 08" and onground == 0 and velocityCheck() and hitchanceSet == false then
		    local jumphc = ui_get(jumpscouthc);
            ui_set(air_strafe, false)
            ui_set(hitchance, jumphc);
            hitchanceSet = true;
        elseif weapon.name == "SSG 08" and onground == 1 and hitchanceSet == true then
            hitchanceSet = false;
            ui_set(hitchance, backuphitchance)
            ui_set(air_strafe, true)
        elseif weapon.name == "SSG 08" and onground == 1 and hitchanceSet == false then
            backuphitchance = ui_get(hitchance)
            ui_set(air_strafe, true)
	    end
    else
        ui_set_visible(jumpscouthc, false)
        ui_set(air_strafe, true)
    end
end)

client.set_event_callback("paint", function(c)
    if ui_get(jumpscout) then
        local vel_x, vel_y = entity.get_prop(entity.get_local_player(), "m_vecVelocity")
        local local_player = entity.get_local_player()
        local flags = entity.get_prop(local_player, "m_fFlags");
        local weapon_ent = entity.get_player_weapon(local_player)
        local weapon_idx = entity.get_prop(weapon_ent, "m_iItemDefinitionIndex")
        local weapon = csgo_weapons[weapon_idx]

        local function velocityCheck()
            if vel_x <= 150 and vel_y <= 150 and vel_x >= -150 and vel_y >= -150 then
                return true
            end
        end

        if local_player == nil then return end
        if weapon_ent == nil then return end
        if weapon_idx == nil then return end
        weapon_idx = bit_band(weapon_idx, 0xFFFF)
        if weapon == nil then return end
	    if flags == nil then return end

        local onground = bit_band(flags, 1);
        
	    if weapon.name == "SSG 08" and onground == 0 and velocityCheck() then
		    renderer_indicator(255, 255, 255, 255, "JS")
	    end
    end
end)