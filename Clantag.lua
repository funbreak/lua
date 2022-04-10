--Clantag-Spammer
ui.new_label("LUA", "A", " ")
ui.new_label("LUA", "A", "------------------   [ Clantag.lua ]    ------------------")
ui.new_label("LUA", "A", " ")
local clanTag = ui.new_combobox("LUA", "A", "Clantag", "Off", "Binary | Code:002", "Write | Code:002", "Inversed | Code:002", "Funky | Code:002", "Cursor | Code:002","Static | Code:002", "Onetap")
local tagSpeed = ui.new_slider("LUA", "A", "Clantag Speed", 1, 10, 5)
ui.set_visible(tagSpeed, false)
ui.new_label("LUA", "A", " ")

------------------------------------------------------------ Start of Clantags -----------------------------------------------------------------
local oldTick, cur = 0, 1
local freezetime

local binary = {
    --Binary Animation
    "11011010",
    "01010011",
    "10111010",
    "01010001",
    "10101100",
    --Binary to Text
    "C0101100",
    "C1001011",
    "Co100101",
    "Co010110",
    "Cod10110",
    "Cod00101",
    "Code0110",
    "Code0101",
    "Code:110",
    "Code:101",
    "Code:001",
    "Code:011",
    "Code:000",
    "Code:001",
    "Code:002",
    "Code:002",
    "Code:002",
    "Code:002",
    "Code:002",
    --Text to Binary
    "Code:002",
    "Code:002",
    "Code:001",
    "Code:000",
    "Code:010",
    "Code:001",
    "Code:101",
    "Code:011",
    "Code1001",
    "Code0101",
    "Cod00110",
    "Cod11001",
    "Co010101",
    "Co010010",
    "C1100101",
    "C1010010"
}
local cursor = { 
    "|",
    "",
    "|",
    "",
    "|",
    "",
    "|",
    "C|",
    "Co|",
    "Cod|",
    "Code|",
    "Code:|",
    "Code:0|",
    "Code:00|",
    "Code:002|",
    "Code:002",
    "Code:002|",
    "Code:002",
    "Code:002|",
    "Code:002",
    "Code:002|",
    "Code:00|",
    "Code:0|",
    "Code:|",
    "Code|",
    "Cod|",
    "Co|",
    "C|"
}
local funky = {
    "",
    "",
    "",
    "[",
    "C",
    "C0",
    "Co",
    "Coδ:",
    "Cod",
    "Cod3",
    "Code",
    "Code|",
    "Code:",
    "Code:o",
    "Code:0",
    "Code:0O",
    "Code:00",
    "Code:00Z",
    "Code:002",
    "Code:002",
    "Code:002",
    "Code:002",
    "Code:002",
    "ode:002",
    "de:002",
    "e:002",
    ":002",
    "002",
    "02",
    "2"
}
local animated = {
    "",
    "",
    "",
    "C",
    "Co",
    "Cod",
    "Code",
    "Code:",
    "Code:0",
    "Code:00",
    "Code:002",
    "Code:002",
    "Code:002",
    "Code:002",
    "Code:002",
    "Code:00",
    "Code:0",
    "Code:",
    "Code",
    "Cod",
    "Co",
    "C"
}
local inversed = {
    "",
    "",
    "",
    "2", 
    "02",
    "002",
    ":002",
    "e:002",
    "de:002",
    "ode:002",
    "Code:002",
    "Code:002",
    "Code:002",
    "Code:002",
    "Code:002",
    "ode:002",
    "de:002",
    "e:002",
    ":002",
    "002",
    "02",
    "2"
}
local static = "Code:002"
local ot = "onetap"


------------------------------------------------------------ End of Clantags -----------------------------------------------------------------

local function clantag()
    local updaterate = 4; --this value can be changed to a higher value if you experience rubberbanding
    local speed = ui.get(tagSpeed)

    if ui.get(clanTag) ~= "Off" then
        if freezetime ~= true then
            if globals.tickcount() - oldTick > updaterate then
                if ui.get(clanTag) == "Binary | Code:002" then
                    cur = math.floor(globals.curtime()* 5 % 40 + 1)
                    client.set_clan_tag(binary[cur])
                    ui.set_visible(tagSpeed, false)
                elseif ui.get(clanTag) == "Write | Code:002" then
                    cur = math.floor(globals.curtime()* speed % 22 + 1)
                    client.set_clan_tag(animated[cur])
                    ui.set_visible(tagSpeed, true)
                elseif ui.get(clanTag) == "Inversed | Code:002" then
                    cur = math.floor(globals.curtime()* speed % 22 + 1)
                    client.set_clan_tag(inversed[cur])
                    ui.set_visible(tagSpeed, true)
                elseif ui.get(clanTag) == "Funky | Code:002" then
                    cur = math.floor(globals.curtime()* 4 % 30 + 1)
                    client.set_clan_tag(funky[cur])
                    ui.set_visible(tagSpeed, false)
                elseif ui.get(clanTag) == "Cursor | Code:002" then
                    cur = math.floor(globals.curtime()* speed % 28 + 1)
                    client.set_clan_tag(cursor[cur])
                    ui.set_visible(tagSpeed, true)
                elseif ui.get(clanTag) == "Static | Code:002" then
                    client.set_clan_tag(static)
                    ui.set_visible(tagSpeed, false)
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
    if string.match(ui.get(clanTag), "Code:002") then
        client.set_clan_tag("Code:002")
        freezetime = true
    elseif ui.get(clanTag)  == "Off" then
        client.set_clan_tag("")
        freezetime = true
    end
end

local function resetFreezetimeTag()
    freezetime = false
end

client.set_event_callback("paint", clantag)
client.set_event_callback("cs_win_panel_match", setFreezetimeTag)
client.set_event_callback("round_poststart", resetFreezetimeTag)

client.set_event_callback("player_connect_full", function(e)
    oldTick = globals.tickcount()
end)

ui.new_label("LUA", "A", " ")
ui.new_label("LUA", "A", "---------------  [ End of Clantag.lua ] ---------------")
ui.new_label("LUA", "A", " ")