--Clantag-Spammer
ui.new_label("LUA", "A", " ")
ui.new_label("LUA", "A", "------------------   [ Diclonius ]    ------------------")
ui.new_label("LUA", "A", " ")
local dicloniusTag = ui.new_combobox("LUA", "A", "Diclonius Clantag", "Off", "Binary", "Static", "Write", "Write Inversed")
local tagSpeed = ui.new_slider("LUA", "A", "Clantag Speed", 1, 10, 5)
ui.set_visible(tagSpeed, false)
ui.new_label("LUA", "A", " ")

--Name-Spammer
local nameSteal = ui.reference("Misc", "Miscellaneous", "Steal player name")
local comboBox  = ui.new_combobox("LUA", "A", "Diclonius Name-Spammer", "Webpage", "Default", "Gothic", "Alienated")

local Presets = {
    ["Webpage"] = "dicloni.us", 
    ["Default"] = "diclonius",
    ["Gothic"] = "𝕯𝖎𝖈𝖑𝖔𝖓𝖎𝖚𝖘",
    ["Alienated"] = "ɖɨƈʟօռɨʊֆ"
}

------------------------------------------------------------ Start of Clantags -----------------------------------------------------------------
local oldTick, cur = 0, 1
local freezetime

local binary = {
    --Animate binary
    "0110011101",
    "1011011001",
    "1011011100",
    "1010100111",
    "1101110100",
    "1111010010",
    "1010101101",
    "0111101010",
    --Animate from binary to text
    "d001110111",
    "d100111101",
    "d101001111",
    "di11010101",
    "di11001011",
    "di01110011",
    "dic0111101", 
    "dic1000111",
    "dic0110011",
    "dicl011110",
    "dicl111001",
    "diclo10111",
    "diclo11110",
    "diclon1101",
    "diclon0111",
    "dicloni101",
    "dicloni010",
    "dicloni.01",
    "dicloni.11",
    "dicloni.u1",
    "dicloni.u0",
    --Let full text stay for a little
    "dicloni.us",
    "dicloni.us",
    "dicloni.us",
    "dicloni.us",
    "dicloni.us",
    "dicloni.us",
    "dicloni.us",
    "dicloni.us",
    --Animate from text to binary
    "dicloni.u1",
    "dicloni.u0",
    "dicloni.10",
    "dicloni.11",
    "dicloni101",
    "dicloni010",
    "diclon1101",
    "diclon0111",
    "diclo10111",
    "diclo11110",
    "dicl011110",
    "dicl111001",
    "dic0111101", 
    "dic1000111",
    "dic0110011",
    "di11010101",
    "di11001011",
    "di01110011",
    "d001110111",
    "d100111101",
    "d101101111"
}
local animated = {
    "♰",
    "♰",
    "♰",
    "♰",
    "♰ d",
    "♰ di",
    "♰ dic",
    "♰ dicl",
    "♰ diclo",
    "♰ diclon",
    "♰ dicloni",
    "♰ dicloni.",
    "♰ dicloni.u",
    "♰ dicloni.us",
    "♰ dicloni.us",
    "♰ dicloni.us",
    "♰ dicloni.u",
    "♰ dicloni.",
    "♰ dicloni",
    "♰ diclon",
    "♰ diclo",
    "♰ dicl",
    "♰ dic",
    "♰ di",
    "♰ d"
}
local inversed = {
    "♰",
    "♰",
    "♰",
    "♰", 
    "♰ s",
    "♰ us",
    "♰ .us",
    "♰ i.us",
    "♰ ni.us",
    "♰ oni.us",
    "♰ loni.us",
    "♰ cloni.us",
    "♰ icloni.us",
    "♰ dicloni.us",
    "♰ dicloni.us",
    "♰ dicloni.us",
    "♰ icloni.us",
    "♰ cloni.us",
    "♰ loni.us",
    "♰ oni.us",
    "♰ ni.us",
    "♰ i.us",
    "♰ .us",
    "♰ us",
    "♰ s",
}
local static = {
    "dicloni.us"
}

------------------------------------------------------------ End of Clantags -----------------------------------------------------------------

local function setName(delay, name)
    client.delay_call(delay, function() 
        client.set_cvar("name", name)
    end)
end

local button =  ui.new_button("LUA", "A", "Spam", function()
    local tempName = nil
    local tempName2 = nil
    ui.set(nameSteal, true)
    tempName = Presets[ui.get(comboBox)]
    tempName2 = tempName .. "​"
    client.set_cvar("name", tempName)
    setName(0.1, tempName2)
    setName(0.2, tempName)
    setName(0.3, tempName2)
    setName(0.4, tempName)
end)

local function clantag()
    speed = ui.get(tagSpeed)
    if ui.get(dicloniusTag) ~= "Off" then
        if freezetime ~= true then
            if globals.tickcount() - oldTick > 4 then
                if ui.get(dicloniusTag) == "Binary" then
                    cur = math.floor(globals.curtime()* 5 % 58 + 1)
                    client.set_clan_tag(binary[cur])
                    ui.set_visible(tagSpeed, false)
                elseif ui.get(dicloniusTag) == "Static" then
                    cur = math.floor(globals.curtime() % 1 + 1)
                    client.set_clan_tag(static[cur])
                    ui.set_visible(tagSpeed, false)
                elseif ui.get(dicloniusTag) == "Write" then
                    cur = math.floor(globals.curtime()* speed % 25 + 1)
                    client.set_clan_tag(animated[cur])
                    ui.set_visible(tagSpeed, true)
                elseif ui.get(dicloniusTag) == "Write Inversed" then
                    cur = math.floor(globals.curtime()* speed % 25 + 1)
                    client.set_clan_tag(inversed[cur])
                    ui.set_visible(tagSpeed, true)
                end
                oldTick = globals.tickcount()
            end
        end
    else
        if freezetime ~= true then
            if globals.tickcount() - oldTick > 8 then
                client.set_clan_tag("")
                oldTick = globals.tickcount()
            end
            ui.set_visible(tagSpeed, false)
        end
    end
end

local function setFreezetimeTag()
    if ui.get(dicloniusTag) ~= "Off" then
        client.set_clan_tag("dicloni.us")
        freezetime = true
    end
end

local function resetFreezetimeTag()
    freezetime = false
end

client.set_event_callback("paint", clantag)
--Applies static clantag on halftime but looks weird as you can see the clantag being applied therefor not used
--client.set_event_callback("announce_phase_end", setFreezetimeTag) 
client.set_event_callback("cs_win_panel_match", setFreezetimeTag)
client.set_event_callback("round_poststart", resetFreezetimeTag)

client.set_event_callback("player_connect_full", function(e)
    oldTick = globals.tickcount()
end)

ui.new_label("LUA", "A", " ")
ui.new_label("LUA", "A", "------------------  [ End of Diclonius ] ------------------")
ui.new_label("LUA", "A", " ")