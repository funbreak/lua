local csgo_weapons = require 'gamesense/csgo_weapons'
local lights = require 'gamesense/source_lights'
local vector = require 'vector'
local ffi = require 'ffi'
local js = panorama.open()


-- | code ------->  pocket  (https://gamesense.pub/forums/viewtopic.php?id=34141)
ffi.cdef[[
    
    struct glow_object_definition_t {
        int m_next_free_slot;
        void *m_ent;
        float r;
        float g;
        float b;
        float a;
        char pad0x4[4];
        float unk1;
        float m_bloom_amount;
        float m_localplayeriszeropoint3;
        bool m_render_when_occluded;
        bool m_render_when_unoccluded;
        bool m_full_bloom_render;
        char pad0x1[1];
        int m_full_bloom_stencil_test_value;
        int m_style;
        int m_split_screen_slot;
    
        static const int END_OF_FREE_LIST = -1;
        static const int ENTRY_IN_USE = -2;
    };
    struct c_glow_object_mngr {
        struct glow_object_definition_t *m_glow_object_definitions;
        int m_max_size;
        int m_pad;
        int m_size;
        struct glow_object_definition_t *m_glow_object_definitions2;
        int m_current_objects;
    }; 
    typedef void*(__thiscall* get_client_entity_t)(void*, int);
]]

local Liner_toggler = ui.new_checkbox('VISUALS', 'Effects', 'Border Lines')
local Glowy_boy = ui.new_checkbox('VISUALS', 'Effects', 'Border Lines Glow')


local cast = ffi.cast

local glow_object_manager_sig = "\x0F\x11\x05\xCC\xCC\xCC\xCC\x83\xC8\x01"
local match = client.find_signature("client.dll", glow_object_manager_sig) or error("sig not found")
local glow_object_manager = cast("struct c_glow_object_mngr**", cast("char*", match) + 3)[0] or error("glow_object_manager is nil")

local rawientitylist = client.create_interface("client_panorama.dll", "VClientEntityList003") or error("VClientEntityList003 wasnt found", 2)
local ientitylist = cast(ffi.typeof("void***"), rawientitylist) or error("rawientitylist is nil", 2)
local get_client_entity = cast("get_client_entity_t", ientitylist[0][3]) or error("get_client_entity is nil", 2)

local function RemoveGlowObjects() 
    for t = 0, glow_object_manager.m_size do 
        local glowobject = cast("struct glow_object_definition_t&", glow_object_manager.m_glow_object_definitions[t])
        glowobject.a = 0
    end
    
end

local function includes(t, val)
    for k,v in ipairs(t) do
        if v == val then
            return true
        end
    end

    return false
end

local function contains(tbl, val)
    for _, v in next, tbl do
        if v == val then return true end
    end
    return false
end

local function render()
    local lp = entity.get_local_player()
    if lp == nil then return end
    local eyeballs = { client.camera_position() }
    local entities = entity.get_all()
    local curtime = globals.curtime()
    ui.set_visible(Glowy_boy, true)
    for i=1,#entities do	
        local e = entities[i]
        local weaponid = entity.get_prop(e, "m_iItemDefinitionIndex")
        local lpent = get_client_entity(ientitylist, e)
        if csgo_weapons[weaponid] then
            local weapon = csgo_weapons(e)
            local owner = entity.get_prop(e, "m_hOwnerEntity")
            if owner == nil then
                local dlight = lights.create_dlight(e)
                local origin_x, origin_y, origin_z = entity.get_origin(e)
                local screen_x, screen_y = renderer.world_to_screen(origin_x, origin_y, origin_z)
                local bop = { client.trace_line(lp, eyeballs[1], eyeballs[2], eyeballs[3], origin_x, origin_y, origin_z) }
                local function Liness(t, val, radius, r, g, b, a, r2, g2, b2, a2, a3, h)
                    if includes(t, val) then
                        if  bop[2] >= 1 then
                            renderer.gradient(screen_x, screen_y-h, 1, h, r, g, b, a, r2, g2, b2, a2, false)
                        end

                        for t = 0, glow_object_manager.m_size do 
                            if glow_object_manager.m_glow_object_definitions[t].m_next_free_slot == -2 and glow_object_manager.m_glow_object_definitions[t].m_ent then 
                                local glowobject = cast("struct glow_object_definition_t&", glow_object_manager.m_glow_object_definitions[t])
                                local glowent = glowobject.m_ent
                                if glowent == lpent then
                                        glowobject.r = r2 / 255 
                                        glowobject.g = g2 / 255 
                                        glowobject.b = b2 / 255
                                        glowobject.a = a3  / 3.5
                                        glowobject.m_style = 0
                                        glowobject.m_render_when_occluded = true
                                        glowobject.m_render_when_unoccluded = false
                                    if ui.get(Glowy_boy) then
                                        if bop[2] >= 1 then
                                            glowobject.m_style = 0
                                        else 
                                            glowobject.a = 0
                                        end
                                    else
                                        glowobject.a = 0
                                    end
                                end
                            end
                        end
                    
                        dlight.origin = vector(origin_x, origin_y, origin_z + 10)
                        dlight.radius = radius
                        dlight:set_color(r2, g2, b2, a3)
                        dlight.key = e
                        dlight.die = curtime + 1
                        dlight.decay = dlight.radius + 100
                    end
                end
                if screen_x ~= nil or screen_y ~= nil then
                    Liness({"knife", "grenade", "melee", "fists"}, weapon.type, 100, 120, 120, 120, 0, 255, 255, 255, 255, 3, 50) -- white
                    Liness({"pistol", "equipment"}, weapon.type, 125, 143, 252, 131, 0, 24, 255, 0, 255, 2, 60) -- green
                    Liness({"shotgun", "machinegun", "taser"}, weapon.type, 150, 131, 141, 252, 0, 0, 20, 242, 255, 2, 70) -- blue
                    Liness({"smg", "stackableitem", "bumpmine"}, weapon.type, 175, 199, 153, 255, 0, 115, 0, 255, 255, 2, 80) -- purple
                    Liness({"rifle", "tablet"}, weapon.type, 200, 252, 120, 5, 0, 255, 72, 0, 255, 2, 90) -- orange
                    Liness({"sniperrifle"}, weapon.type, 300, 255, 156, 156, 0, 250, 0, 0, 255, 2, 100) -- red
                    Liness({"c4", "breachcharge"}, weapon.type, 250, 255, 253, 143, 0, 255, 251, 0, 255, 2, 105) -- yellow
                end
            end
        end
    end   
end

client.set_event_callback("paint", function()
    if ui.get(Liner_toggler) then
        render() 
    else
        ui.set_visible(Glowy_boy, false)
    end 
end)

client.set_event_callback("shutdown", function()
    RemoveGlowObjects()
end)