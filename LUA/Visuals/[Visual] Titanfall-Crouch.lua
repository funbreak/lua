local csgo_weapons = require "gamesense/csgo_weapons"
local entity = require "gamesense/entity"
local ffi = require("ffi")

-- Menu Items
local model = ui.new_checkbox('Lua', 'A', 'Titanfall crouch')

-- Variables
local local_player
local anim_state
local duck_amount
local weapon
local weapon_id

-- References
local fd = ui.reference("Rage", "Other", "Duck peek assist")

-- Positions (Makes it so some weapons don't overcrowd)
local wep_pos = {
	pistol = {-3.2, -1.0, -4.5, -45},
	smg = {-3.2, -1.0, -4.5, -45},
	machinegun = {-4.2, 3.0, -7.5, -45},
	shotgun = {-3.2, -1.0, -4.5, -45},
	grenade = {-1.2, -1.0, -1.5, -45},
	rifle = {-1.2, 5.0, -5.5, -45},
	sniperrifle = {-1.2, 5.0, -5.5, -35},
	taser = {-3.2, -1.0, -4.5, -45},
	breachcharge = {-0.4, 2.0, -0.6, 0},
	bumpmine = {-0.4, 2.0, -0.6, 0},
	tablet = {-0.4, 2.0, -0.6, 0},
	fists = {-0.4, 2.0, -0.6, 0},
	knife = {-0.4, 2.0, -0.6, 0},
	c4 = {-0.4, 2.0, -0.6, 0},
}

-- Code Yoinked from public view model changer
local ffi_to = {
    classptr = ffi.typeof('void***'),
    client_entity = ffi.typeof('void*(__thiscall*)(void*, int)'),

    set_angles = (function()
        ffi.cdef('typedef struct { float x; float y; float z; } vmodel_vec3_t;')

        return ffi.typeof('void(__thiscall*)(void*, const vmodel_vec3_t&)')
    end)()
}

local rawelist = client.create_interface('client_panorama.dll', 'VClientEntityList003') or error('VClientEntityList003 is nil', 2)
local ientitylist = ffi.cast(ffi_to.classptr, rawelist) or error('ientitylist is nil', 2)
local get_client_entity = ffi.cast(ffi_to.client_entity, ientitylist[0][3]) or error('get_client_entity is nil', 2)

local set_angles = client.find_signature('client_panorama.dll', '\x55\x8B\xEC\x83\xE4\xF8\x83\xEC\x64\x53\x56\x57\x8B\xF1') or error('Couldn\'t find set_angles signature!')
local set_angles_fn = ffi.cast(ffi_to.set_angles, set_angles) or error('Couldn\'t cast set_angles_fn')

local function lerp(a, b, percentage)
	return a + (b - a) * percentage
end

local function on_paint()
	local_player			= entity.get_local_player()
	anim_state = local_player:get_anim_state()
	if anim_state == nil then return end
	duck_amount				= anim_state.duck_amount
	weapon 	 				= entity.get_player_weapon(local_player)
	weapon_id 				= entity.get_prop(weapon, 'm_iItemDefinitionIndex')
end

local function on_pre_render()
	if local_player == nil or weapon == nil then return end
	local type = csgo_weapons[weapon_id].type
	if ui.get(model) then
		if entity.get_prop(weapon, "m_bInReload") ~= 1 and entity.get_prop(local_player, "m_bIsScoped") ~= 1 and not ui.get(fd) then
			local view = wep_pos[type]
			cvar.viewmodel_offset_x:set_raw_float(lerp(-0.4, view[1], duck_amount))
			cvar.viewmodel_offset_y:set_raw_float(lerp(2.0, view[2], duck_amount))
			cvar.viewmodel_offset_z:set_raw_float(lerp(-0.6, view[3], duck_amount))
		else
			cvar.viewmodel_offset_x:set_raw_float(-0.4)
			cvar.viewmodel_offset_y:set_raw_float(2.0)
			cvar.viewmodel_offset_z:set_raw_float(-0.6)
		end
	end
end

local function on_override_view()
	if local_player == nil or weapon == nil then return end
	local type = csgo_weapons[weapon_id].type
	if ui.get(model) and entity.get_prop(weapon, "m_bInReload") ~= 1 and entity.get_prop(local_player, "m_bIsScoped") ~= 1 and not ui.get(fd) then
		local view = wep_pos[type]
		local viewmodel = entity.get_prop(local_player, 'm_hViewModel[0]')

		if viewmodel == nil then return end

		local viewmodel_ent = get_client_entity(ientitylist, viewmodel)

		if viewmodel_ent == nil then return end

		local camera_angles = { client.camera_angles() }
		local angles = ffi.cast('vmodel_vec3_t*', ffi.new('char[?]', ffi.sizeof('vmodel_vec3_t')))

		angles.x, angles.y, angles.z = 
			camera_angles[1], camera_angles[2], lerp(0, view[4], duck_amount)

		set_angles_fn(viewmodel_ent, angles)
	end
end

client.set_event_callback("paint", on_paint)
client.set_event_callback("pre_render", on_pre_render)
client.set_event_callback("override_view", on_override_view)