local PingLowAmount = 60
local PingHighAmount = 130 
local FakeLatencyFlag = ui.new_checkbox("LUA", "A", "Fake Latency flag")
local CCSPlayerResource = entity.get_all("CCSPlayerResource")[1]

local function GetPlayerResource(Prop,EntIndex)
    local Prop = entity.get_prop(CCSPlayerResource, Prop, EntIndex)
    return Prop
end
    
client.register_esp_flag("FL", 255, 0, 0, function(ent)
    local TargetPing = GetPlayerResource("m_iPing", ent) 
	if TargetPing ~= nil then
    if ui.get(FakeLatencyFlag) and TargetPing > PingHighAmount then
        return true, "BT"
    	end
    end
end)

client.register_esp_flag("FL", 235, 186, 52, function(ent)
    local TargetPing = GetPlayerResource("m_iPing", ent) 
	if TargetPing ~= nil then
    if ui.get(FakeLatencyFlag) and TargetPing > PingLowAmount and TargetPing < PingHighAmount then
        return true, "BT"
    	end
    end
end)





