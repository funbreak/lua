local checkbox = ui.new_checkbox("VISUALS", "Effects", "Hit Effect")
local color = ui.new_color_picker("VISUALS", "Effects", "Effect Color", 255, 55, 55, 255)
local rspeed = ui.new_slider("VISUALS", "Effects", "Effect Reset Speed", 3, 30, 15, true, "", 0.1)
local strength = ui.new_slider("VISUALS", "Effects", "Effect Strength", 1, 5, 2, true, "", 1)
local red, green, blue, alpha, m = 0
local w, h = client.screen_size()

local function setvis()
    bool = ui.get(checkbox)
    ui.set_visible(rspeed, bool)
    ui.set_visible(color, bool)
    ui.set_visible(strength, bool)
end

local function killeffect(e)
    if not ui.get(checkbox) then 
        return 
    end

    local attacker = client.userid_to_entindex(e.attacker)
    local me = entity.get_local_player()

    if attacker == me then
        alpha = 255
    end
end

local function on_paint()
    if not ui.get(checkbox) or not alpha then 
        return 
    end

    mode = ui.get(strength)
    if mode == 1 then 
        m = 50 
    elseif mode == 2 then 
        m = 8 
    elseif mode == 3 then 
        m = 6 
    elseif mode == 4 then 
        m = 4 
    elseif mode == 5 then 
        m = 2 
    end

    if alpha > 0 then
        red, green, blue = ui.get(color)
        renderer.gradient(0, 0, w/m, h, red, green, blue, alpha, 0, 0, 0, 0, true)
        renderer.gradient(0, 0, w, h/m, red, green, blue, alpha, 0, 0, 0, 0, false)
        renderer.gradient(w, h, -(w/m), -h, red, green, blue, alpha, 0, 0, 0, 0, true)
        renderer.gradient(w, h, -w, -(h/m), red, green, blue, alpha, 0, 0, 0, 0, false)
        alpha = alpha - (ui.get(rspeed)/10)
    end
end

setvis()
ui.set_callback(checkbox, setvis)
client.set_event_callback("player_hurt", killeffect)
client.set_event_callback("paint", on_paint)