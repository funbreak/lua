---@diagnostic disable: undefined-global
--#region requirements
local libraries = {
    {"steamworks", "26526"},
    {"http", "19253"}
}
local _ENV = getfenv()
for _, library in ipairs(libraries) do
    local success, loaded_library = pcall(require, ("gamesense/") .. library[1])
    if success then
        _ENV[library[1]] = loaded_library
    else
        local link = " |  https://gamesense.pub/forums/viewtopic.php?id=" .. library[2]
        error("Missing requirement: " ..  "gamesense/" .. lib[1] .. link, 2)
    end
end

local ISteamFriends = steamworks.ISteamFriends
local EPersonaState = steamworks.EPersonaState
local js = panorama.open()
local local_steamid = js.MyPersonaAPI.GetXuid()

--#endregion

local friendlist = -- owner : invisible text for easier searching
{
    {steamid = "76561199389239564", owner = "GSTAR Gerd"}, -- GSTAR
    {steamid = "76561199365552083", owner = "GSTAR Gerd"}, -- Special agent Bart Simpson
    {steamid = "76561198956470136", owner = "GSTAR Gerd"}, -- 2 Liliputaner in einem Kostüm
    {steamid = "76561199059168063", owner = "GSTAR Gerd"}, -- Joey
    {steamid = "76561198942767885", owner = "GSTAR Gerd"}, -- Oggy
    {steamid = "76561199059378812", owner = "GSTAR Gerd"}, -- gangsta cat
    {steamid = "76561198971765798", owner = "GSTAR Gerd"}, -- Lenny
    {steamid = "76561199061814920", owner = "GSTAR Gerd"}, -- Piss Gobling
    {steamid = "76561199500785428", owner = "GSTAR Gerd"}, -- gstar 

    {steamid = "76561198153255176", owner = "funbreak Kev"}, -- funbreak
    {steamid = "76561199477992426", owner = "funbreak Kev"}, -- 勝
    {steamid = "76561199496383321", owner = "funbreak Kev"}, -- 愛

    {steamid = "76561198246896906", owner = "Nick"}, -- Nick430
    {steamid = "76561198981806499", owner = "Nick"}, -- Detall Metektor
    {steamid = "76561198856399259", owner = "Nick"}, -- Stullenhalter
    {steamid = "76561198914066826", owner = "Nick"}, -- Pixel-Inspector
    {steamid = "76561199182527968", owner = "Nick"}, -- Toto
    {steamid = "76561198975506330", owner = "Nick"}, -- Nut Master
    {steamid = "76561199072903182", owner = "Nick"}, -- PEOLEokx

    {steamid = "76561198984017055", owner = "Digital Max"}, -- digital
    {steamid = "76561199043172030", owner = "Digital Max"}, -- г фредо aka g fredo

    {steamid = "76561199489158510", owner = "Eclipse Lucifer Sascha"}, -- Eclipse_Lυciғεя
    {steamid = "76561198297444536", owner = "Eclipse Lucifer Sascha"}, -- NûR_âM_PêPpÊN
    {steamid = "76561198286998094", owner = "Eclipse Lucifer Sascha"}, -- ^40êr KâNnTHôLz
    {steamid = "76561199085561561", owner = "Eclipse Lucifer Sascha"}, -- Der der mit der Stulle tanzt 
    {steamid = "76561199049271683", owner = "Eclipse Lucifer Sascha"}, -- 那句晚安她听了吗
    {steamid = "76561198029652320", owner = "Eclipse Lucifer Sascha"}, -- 1
    {steamid = "76561199180535481", owner = "Eclipse Lucifer Sascha"}, -- bb7784160
    --{steamid = "76561199170403882", owner = "Eclipse Lucifer Sascha"}, -- joaquinjones1113
}

--#region ui elements
local ui_elements = {}
ui_elements.master_switch = ui.new_checkbox("LUA", "B", "Friendlist")
ui_elements.listbox = ui.new_listbox("LUA", "B", "Friendlistbox", {})
ui_elements.profile_button = ui.new_button("LUA", "B", "Open steam profile", function()end)
ui_elements.invite_button =  ui.new_button("LUA", "B", "Invite to lobby", function()end)
--#endregion

--#region functions
local functions = {}

functions.get_rich_data = function(steamid)
    ISteamFriends.RequestFriendRichPresence(steamid)
    ISteamFriends.RequestUserInformation(steamid, true)
    local data = {}
	local id = steamworks.SteamID(steamid)
	local max = ISteamFriends.GetFriendRichPresenceKeyCount(id)
	if max == 0 then return {} end
	for i = 0, max do
		local key = ISteamFriends.GetFriendRichPresenceKeyByIndex(id, i)
		local value = ISteamFriends.GetFriendRichPresence(id, key)
		data[key] = value
	end
	return data
end

functions.update_listbox = function()
    table.sort(friendlist, function(a, b)
		if a.last_seen == b.last_seen then
			return a.steamid > b.steamid
		else
			return a.last_seen > b.last_seen
		end
	end)

    local friends = {}
    for i, friend in ipairs(friendlist) do
        if friend.steamid == local_steamid then
            table.remove(friendlist, i)
        end
        local rich_presence = friend.rich_data or {}
        local has_rich_presence = next(rich_presence)
        local status = ("%s● %s%s %s%s"):format(has_rich_presence and "\a90BA3CFF" or friend.status == "Online" and "\a57CBDEFF" or "\a898989FF", "\aFFFFFFC8", friend.nickname, "\aFFFFFF00", friend.owner)
        table.insert(friends, status)
    end
    ui.update(ui_elements.listbox, friends) -- fill the listbox
end

local got_info = {}
functions.fetch_steam_data = function() -- get steam names and refresh rich data
    for _, friend in ipairs(friendlist) do

        if not got_info[friend.steamid] then
            friend.nickname = "fetching name..."
            friend.last_seen = 0
        end

        local steamid_object = steamworks.SteamID(friend.steamid)
        local steamid64 = steamid_object:render_steam64()
        http.get("https://steamcommunity.com/profiles/" .. steamid64, {params = {xml = 1}}, function(_, r)
            if r.status == 200 then
                local match = r.body:match("<steamID><%!%[CDATA%[(.+)%]%]></steamID>")
				if match then
					friend.nickname = match
                    got_info[friend.steamid] = true
                end

                local persona_state = ISteamFriends.GetFriendPersonaState(steamid64)
                friend.status = EPersonaState[persona_state]
                friend.rich_data = functions.get_rich_data(steamid64)

                if next(functions.get_rich_data(steamid64)) then
					friend.last_seen = client.unix_time() + 1
                elseif EPersonaState[persona_state] == "Online" then
                    friend.last_seen = client.unix_time()
                end
            end
        end)
    end
end
--#endregion

--#region callbacks
local callbacks = {}
callbacks.master_switch = function(self)
    local enabled = ui.get(self)
    local update_callback = enabled and client.set_event_callback or client.unset_event_callback
    update_callback("paint_ui", callbacks.main)
    ui.set_visible(ui_elements.listbox, enabled)
    if enabled == false then
        ui.set_visible(ui_elements.profile_button, false)
        ui.set_visible(ui_elements.invite_button, false)
    end
end

callbacks.old_list_state = 0
callbacks.listbox = function(self)
    local state = ui.get(self)
    if state ~= callbacks.old_list_state then
        callbacks.old_list_state = state
    end
    if not state then
        ui.set_visible(ui_elements.profile_button, false)
        ui.set_visible(ui_elements.invite_button, false)
        return
    end
    local index = state + 1
	local data = friendlist[index] or {}
    ui.set_visible(ui_elements.profile_button, true)
    ui.set_visible(ui_elements.invite_button, data.rich_data)
    functions.update_listbox()
end

callbacks.profile_button = function()
    local list_state = ui.get(ui_elements.listbox)
    if not list_state then return end
    local index = list_state + 1
	js.SteamOverlayAPI.ShowUserProfilePage(friendlist[index].steamid)
end

callbacks.invite_button = function()
    local list_state = ui.get(ui_elements.listbox)
    if not list_state then return end
    local index = list_state + 1 -- #2 way to invite people (panorama friendslistapi call)
    js.FriendsListAPI.ActionInviteFriend(friendlist[index].steamid, "")
end

callbacks.last_refresh = 0
callbacks.main = function()
    if ui.is_menu_open() == false then goto skip_update end

    if globals.realtime() - 2 > callbacks.last_refresh then
        functions.fetch_steam_data()
        functions.update_listbox()
        callbacks.last_refresh = globals.realtime()
    end

    ::skip_update::
end

ui.set_callback(ui_elements.master_switch, callbacks.master_switch)
callbacks.master_switch(ui_elements.master_switch)

ui.set_callback(ui_elements.listbox, callbacks.listbox)
callbacks.listbox(ui_elements.listbox)

ui.set_callback(ui_elements.profile_button, callbacks.profile_button)
ui.set_callback(ui_elements.invite_button, callbacks.invite_button)

client.set_event_callback("post_config_load", function()
    ui.set_visible(ui_elements.profile_button, false)
    ui.set_visible(ui_elements.invite_button, false)
    ui.set_visible(ui_elements.invite_spam_checkbox, false)
end)
--#endregion