local PingAmount = 75 --set this to the amount of ping you want the target to have before setting the flag
local FakeLatencyFlag = ui.new_checkbox("Visuals", "Other ESP", "Fake Latency flag")
local CCSPlayerResource = entity.get_all("CCSPlayerResource")[1]

local function GetPlayerResource(Prop,EntIndex)
    local Prop = entity.get_prop(CCSPlayerResource, Prop, EntIndex)
    return Prop
    end

client.register_esp_flag("FL", 220, 216, 216, function(ent)
    local TargetPing = GetPlayerResource("m_iPing", ent) 
	if TargetPing ~= nil then
    if ui.get(FakeLatencyFlag) and TargetPing > PingAmount then
        return true, "MS"
    	end
    end
end)