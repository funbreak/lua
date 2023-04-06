local enabled_reference = ui.new_checkbox("MISC", "Miscellaneous", "Log damage received")

local client_userid_to_entindex = client.userid_to_entindex
local client_log = client.log
local entity_get_players = entity.get_players
local entity_get_prop = entity.get_prop
local entity_get_player_name = entity.get_player_name
local entity_get_local_player = entity.get_local_player
local ui_get = ui.get

local hitgroup_names = { "body", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear" }

local function on_player_hurt(e)
	if not ui_get(enabled_reference) then
		return
	end

	local userid, attacker, health, armor, weapon, dmg_health, dmg_armor, hitgroup = e.userid, e.attacker, e.health, e.armor, e.weapon, e.dmg_health, e.dmg_armor, e.hitgroup

	if userid == nil or attacker == nil or hitgroup < 0 or hitgroup > 10 or dmg_health == nil or health == nil then
		return
	end

	if client_userid_to_entindex(userid) == entity_get_local_player() then
		
		local hitbox_hit = hitgroup_names[hitgroup + 1]
		
		if hitbox_hit then
			client_log("hit by ", entity_get_player_name(client_userid_to_entindex(attacker)),
				" in the ", hitbox_hit,
				" for ", dmg_health,
				" damage (" , health, " health remaining)")
		end
	end
end

client.set_event_callback("player_hurt", on_player_hurt)