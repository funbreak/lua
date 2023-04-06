local ffi = require( "ffi" )

local function ReadUInt( address )
    return ffi.cast( "unsigned int*", address )[0]
end

local function GetItemIndex( targetTable, item )
    for i=1,table.getn( targetTable ) do
        if targetTable[i] == item then
            return i
        end
    end
end

local FindPattern = client.find_signature
local SetEventCallback = client.set_event_callback
local SetUICallback = ui.set_callback
local GetEntIndex = client.userid_to_entindex
local GetLocalPlayer = entity.get_local_player

local registerGlowObjectPattern = "\xE8\xCC\xCC\xCC\xCC\x89\x03\xEB\x02"
local getGlowObjectManagerPattern = "\xA1\xCC\xCC\xCC\xCC\xA8\x01\x75\x4B"

local clientEntityList
local engineClient

-- ffi related setup

local GetGlowObjectManager_t = "struct CGlowObjectManager*( __cdecl* )( )"
local RegisterGlowObject_t = "int( __thiscall* )( struct CGlowObjectManager*, void*, const Vector&, bool, bool, int )"
-- Function prototype is technically incorrect, there should be another parameter, but it is passed through the xmm3 register
-- so it must be removed to avoid messing up the stack, values will be overwritten later anyway so the value set by this call shouldn't matter
local GetClientEntity_t = "void*( __thiscall* )( void*, int )"
local IsInGame_t = "bool( __thiscall* )( void* )"

local RegisterGlowObject
local GetGlowObjectManager
local GetClientEntityRaw
local IsInGameRaw

ffi.cdef[[
    struct Vector
    {
        float r, g, b;
    };

    struct CAllocator_GlowObjectDefinition_t //Haven't done a lot of research but templates don't seem to work with ffi.cdef so I'm left with this
    {
        struct GlowObjectDefinition_t *m_pMemory;
        int m_nAllocationCount;
        int m_nGrowSize;
    };

    struct CUtlVector_GlowObjectDefinition_t 
    {
        struct CAllocator_GlowObjectDefinition_t m_Memory;
        int m_Size;
        struct GlowObjectDefinition_t *m_pElements;
    };

    struct GlowObjectDefinition_t
    {
        void *m_pEntity;
        struct Vector m_vGlowColor;
        float m_flGlowAlpha;
        char pad01[16];
        bool m_bRenderWhenOccluded;
        bool m_bRenderWhenUnoccluded;
        bool m_bFullBloomRender;
        char pad02;
        int m_nFullBloomStencilTestValue;
        int m_nRenderStyle;
        int m_nSplitScreenSlot;
        int m_nNextFreeSlot;
        //Total size: 0x38 bytes
    };

    struct CGlowObjectManager
    {
        struct CUtlVector_GlowObjectDefinition_t m_GlowObjectDefinitions;
        int m_nFirstFreeSlot;
    };
]]

-- Script specific setup

local glowObjectIndexes = { }

local localPlayerGlowEnabled = ui.new_checkbox( "Visuals", "Player ESP", "Local player glow" )

local glowStyles = { "Default", "Rim Glow 3D", "Edge Highlight", "Edge Highlight Pulse" }
local glowObjectSelector = ui.new_combobox("Visuals", "Player ESP", "Glow Style", glowStyles)

local glowObjectEnabled = {
    ui.new_checkbox( "Visuals", "Player ESP", "[Default] Enabled" ), 
    ui.new_checkbox( "Visuals", "Player ESP", "[Rim Glow 3D] Enabled" ), 
    ui.new_checkbox( "Visuals", "Player ESP", "[Edge Highlight] Enabled" ), 
    ui.new_checkbox( "Visuals", "Player ESP", "[Edge Highlight Pulse] Enabled" )
}

local glowObjectColor = {
    ui.new_color_picker( "Visuals", "Player ESP", "[Default] Color" ), 
    ui.new_color_picker( "Visuals", "Player ESP", "[Rim Glow 3D] Color", 18, 48, 56, 143 ), 
    ui.new_color_picker( "Visuals", "Player ESP", "[Edge Highlight] Color" ), 
    ui.new_color_picker( "Visuals", "Player ESP", "[Edge Highlight Pulse] Color", 255, 69, 69, 53 )
}

-- Function definitions

local function GetClientEntity( index )
    return GetClientEntityRaw( clientEntityList, index )
end

local function IsInGame( )
    return IsInGameRaw( engineClient )
end

local function InitMethods( )
    GetGlowObjectManager = ffi.cast( GetGlowObjectManager_t, FindPattern( "client.dll", getGlowObjectManagerPattern ) )
    RegisterGlowObject = ffi.cast( "unsigned int", FindPattern( "client.dll", registerGlowObjectPattern ) )
    RegisterGlowObject = ffi.cast( RegisterGlowObject_t, RegisterGlowObject + 5 + ReadUInt (RegisterGlowObject + 1 ) )
    clientEntityList = client.create_interface( "client.dll", "VClientEntityList003" )
    GetClientEntityRaw = ffi.cast( GetClientEntity_t, ReadUInt( ReadUInt( ffi.cast( "unsigned int", clientEntityList ) ) + 3 * 4 ) )
    engineClient = client.create_interface( "engine.dll", "VEngineClient014" )
    IsInGameRaw = ffi.cast( IsInGame_t, ReadUInt( ReadUInt( ffi.cast( "unsigned int", engineClient ) ) + 26 * 4 ) )
end

local function CreateGlowObject( ent, color, alpha, style )
    local glowObjectManager = GetGlowObjectManager( )
    local index = RegisterGlowObject( glowObjectManager, ffi.cast( "void*", ent ), ffi.new( "Vector", color ), true, true, -1 )
    glowObjectManager.m_GlowObjectDefinitions.m_Memory.m_pMemory[index].m_vGlowColor = color
    glowObjectManager.m_GlowObjectDefinitions.m_Memory.m_pMemory[index].m_flGlowAlpha = alpha
    glowObjectManager.m_GlowObjectDefinitions.m_Memory.m_pMemory[index].m_nRenderStyle = style
    glowObjectManager.m_GlowObjectDefinitions.m_Memory.m_pMemory[index].m_bRenderWhenOccluded = true
    glowObjectManager.m_GlowObjectDefinitions.m_Memory.m_pMemory[index].m_bRenderWhenUnoccluded = true
    table.insert( glowObjectIndexes, index )
end

local function SetGlowObjectColor( index, color, alpha )
    local glowObjectManager = GetGlowObjectManager( )
    glowObjectManager.m_GlowObjectDefinitions.m_Memory.m_pMemory[index].m_vGlowColor = color
    glowObjectManager.m_GlowObjectDefinitions.m_Memory.m_pMemory[index].m_flGlowAlpha = alpha
end

local function SetGlowObjectRender( index, status )
    local glowObjectManager = GetGlowObjectManager( )
    glowObjectManager.m_GlowObjectDefinitions.m_Memory.m_pMemory[index].m_bRenderWhenOccluded = status
    glowObjectManager.m_GlowObjectDefinitions.m_Memory.m_pMemory[index].m_bRenderWhenUnoccluded = status
end

local function InitGlowObjects( )
    local localPlayer = GetClientEntity( GetLocalPlayer( ) )
    -- Four objects for the four styles
    CreateGlowObject( localPlayer, { 0.0, 0.0, 0.0 }, 0.0, 0 ) -- DEFAULT
    CreateGlowObject( localPlayer, { 0.0, 0.0, 0.0 }, 0.0, 1 ) -- RIMGLOW3D
    CreateGlowObject( localPlayer, { 0.0, 0.0, 0.0 }, 0.0, 2 ) -- EDGE_HIGHLIGHT
    CreateGlowObject( localPlayer, { 0.0, 0.0, 0.0 }, 0.0, 3 ) -- EDGE_HIGHLIGHT_PULSE
    for i=1, table.getn( glowObjectIndexes ) do
        r, g, b, a = ui.get( glowObjectColor[i] )
        if ui.get( localPlayerGlowEnabled ) == false or ui.get( glowObjectEnabled[i] ) == false then
            SetGlowObjectRender( glowObjectIndexes[i], false )
        else
            SetGlowObjectRender( glowObjectIndexes[i], true )
        end
        SetGlowObjectColor( glowObjectIndexes[i], { r / 255, g / 255, b / 255 }, a / 255 )
    end
end

local function RemoveGlowObjects( ) -- Destroy created glow objects and clear the glowObjectIndex list
    local glowObjectManager = GetGlowObjectManager( )
    for i=1, table.getn( glowObjectIndexes ) do
        glowObjectManager.m_GlowObjectDefinitions.m_Memory.m_pMemory[glowObjectIndexes[i]].m_nNextFreeSlot = glowObjectManager.m_nFirstFreeSlot
        glowObjectManager.m_GlowObjectDefinitions.m_Memory.m_pMemory[glowObjectIndexes[i]].m_pEntity = ffi.cast( "void*", 0 )
        glowObjectManager.m_nFirstFreeSlot = glowObjectIndexes[i]
    end
    glowObjectIndexes = { }
end

local function OnPlayerConnectFull( evt )
    if GetEntIndex( evt.userid ) == GetLocalPlayer( ) then
        InitGlowObjects( )
    end
end

local function OnPaintUI( ) -- Lame way of doing this, ideally I'd use a callback for when the player disconnects but I haven't managed to find one (I've tried cs_game_disconnected and it doesn't seem to get called) so if you know one please let me know
    if IsInGame( ) == false and glowObjectIndexes[1] ~= nil then
        RemoveGlowObjects( )
    end
end

local function OnPreConfigLoad( )
    if IsInGame( ) == true then
        RemoveGlowObjects( )
    end
end

local function OnPostConfigLoad( )
    if IsInGame( ) == true then
        client.delay_call( 0.3, InitGlowObjects ) -- For some reason the game was crashing if I called this immediately or even with a delay of 0.1
    end
end

local function OnUIRenderElementChanged( item ) -- May aswell update all of them, it's only called when changed so overhead is negligable
    if IsInGame( ) == true then
        for i=1, table.getn( glowObjectIndexes ) do
            r, g, b, a = ui.get( glowObjectColor[i] )
            if ui.get( localPlayerGlowEnabled ) == false or ui.get( glowObjectEnabled[i] ) == false then
                SetGlowObjectRender( glowObjectIndexes[i], false )
            else
                SetGlowObjectRender( glowObjectIndexes[i], true )
            end
            SetGlowObjectColor( glowObjectIndexes[i], { r / 255, g / 255, b / 255 }, a / 255 )
        end
    end
end

local function OnGlowStyleChanged( item )
    local index = GetItemIndex( glowStyles, ui.get( item ) )
    for i=1, table.getn( glowStyles ) do
        local status = i == index
        ui.set_visible( glowObjectEnabled[i], status )
        ui.set_visible( glowObjectColor[i], status )
    end
end

-- =====================================
InitMethods( )

if IsInGame( ) then
    InitGlowObjects( )
end

SetEventCallback( "shutdown", RemoveGlowObjects )
SetEventCallback( "player_connect_full", OnPlayerConnectFull )
SetEventCallback( "paint_ui", OnPaintUI )
SetEventCallback( "pre_config_load", OnPreConfigLoad )
SetEventCallback( "post_config_load", OnPostConfigLoad )

for i=1, table.getn( glowStyles ) do
    if i ~= 1 then
        ui.set_visible( glowObjectEnabled[i], false )
        ui.set_visible( glowObjectColor[i], false )
    end
    SetUICallback( glowObjectEnabled[i], OnUIRenderElementChanged )
    SetUICallback( glowObjectColor[i], OnUIRenderElementChanged )
end
SetUICallback( localPlayerGlowEnabled, OnUIRenderElementChanged )

SetUICallback( glowObjectSelector, OnGlowStyleChanged )