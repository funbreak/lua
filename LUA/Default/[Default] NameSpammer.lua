local nameSteal = ui.reference("Misc", "Miscellaneous", "Steal player name")
local enableBox = ui.new_checkbox("Misc", "Miscellaneous", "Name changer")
local comboBox  = ui.new_combobox("Misc", "Miscellaneous", " ","Funbreak | Default", "Funbreak | Topdown", "Funbreak | Gothic", "Funbreak | Spaced", "Funbreak | Small", "Steam Link", "Discord", "Custom")

local Presets = {
    ["Funbreak | Default"] = "funbreak.-", 
    ["Funbreak | Topdown"] = "ʞɐǝɹqunɟ",
    ["Funbreak | Gothic"] = "𝖋𝖚𝖓𝖇𝖗𝖊𝖆𝖐", 
    ["Funbreak | Spaced"] = "ｆｕｎｂｒｅａｋ",
    ["Funbreak | Small"] = "ᶠᵘⁿᵇʳᵉᵃᵏ",
    ["Steam Link"] = "id/autistisch",
    ["Discord"] = "funbreak#0088",
    ["Custom"] = nil
}

local function setName(delay, name)
    client.delay_call(delay, function() 
        client.set_cvar("name", name)
    end)
end
local textBox   = ui.new_textbox("Misc", "Miscellaneous", "Input")
local button =  ui.new_button("Misc", "Miscellaneous", "Spam", function()
    if not ui.get(enableBox) then return end
        local tempName = nil
        local tempName2 = nil
        ui.set(nameSteal, true)
        if ui.get(comboBox) == "Custom" then tempName = ui.get(textBox)
        else tempName = Presets[ui.get(comboBox)] end
            tempName2 = tempName .. "​"
            client.set_cvar("name", tempName)
            setName(0.1, tempName2)
            setName(0.2, tempName)
            setName(0.3, tempName2)
            setName(0.4, tempName)
end)

local function handleMenu()
    local state = ui.get(enableBox)
        ui.set_visible(comboBox, state)
        ui.set_visible(button, state)
        if state then if ui.get(comboBox) == "Custom" then ui.set_visible(textBox, true) end 
        else ui.set_visible(textBox, false) end
end

local function handleMenu2()
    if not ui.get(enableBox) then return end
    if ui.get(comboBox) == "Custom" then ui.set_visible(textBox, true) 
    else ui.set_visible(textBox, false) end
end
handleMenu() handleMenu2()
ui.set_callback(enableBox, handleMenu)
ui.set_callback(comboBox, handleMenu2)
