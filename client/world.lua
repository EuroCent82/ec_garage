--- Blips, Props und Target — stabil nach DB-Sync (Props bleiben persistent)

local blips = {}
local props = {}
local loadedModels = {}
local refreshToken = 0
local hasSynced = false

local function clearBlip(handle)
    if handle and DoesBlipExist(handle) then
        RemoveBlip(handle)
    end
end

local function clearPropEntity(entity)
    if entity and DoesEntityExist(entity) then
        DeleteEntity(entity)
    end
end

local function garageKey(garage)
    return tostring(garage.id)
end

local function resolvePropZ(x, y, z)
    if Config.PropUseGroundZ == false then
        return z
    end
    local found, groundZ = GetGroundZFor_3dCoord(x, y, z + 2.0, false)
    if found then
        return groundZ
    end
    return z
end

local function requestModel(hash)
    if loadedModels[hash] then
        return true
    end
    if not IsModelInCdimage(hash) then
        return false
    end
    RequestModel(hash)
    local timeout = GetGameTimer() + 8000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(50)
    end
    if HasModelLoaded(hash) then
        loadedModels[hash] = true
        return true
    end
    return false
end

local function spawnGarageProp(garage)
    local prop = garage.prop
    if not prop or not prop.model or not prop.x or prop.enabled == false then
        return nil
    end

    local key = garageKey(garage)
    local existing = props[key]
    if existing and DoesEntityExist(existing) then
        return existing
    end

    local model = joaat(prop.model)
    if not requestModel(model) then
        print(('^3[ec_garage]^7 Prop-Modell nicht ladbar: %s (%s)'):format(prop.model, key))
        return nil
    end

    local x, y, z = prop.x + 0.0, prop.y + 0.0, prop.z + 0.0
    z = resolvePropZ(x, y, z)

    local obj = CreateObject(model, x, y, z, false, false, false)
    if not obj or obj == 0 then
        return nil
    end

    SetEntityHeading(obj, prop.h or 0.0)
    if Config.PropSnapToGround then
        PlaceObjectOnGroundProperly(obj)
    else
        SetEntityCoords(obj, x, y, z, false, false, false, true)
    end

    FreezeEntityPosition(obj, true)
    SetEntityInvincible(obj, true)
    SetEntityCanBeDamaged(obj, false)
    SetEntityAsMissionEntity(obj, true, true)
    SetEntityLodDist(obj, 500)

    props[key] = obj

    if Config.InteractMode ~= 'marker' then
        ECGarage.Target.Register(garage, obj)
    end

    return obj
end

local function spawnGaragePropAsync(garage, token)
    CreateThread(function()
        for attempt = 1, 4 do
            if token ~= refreshToken then
                return
            end
            local obj = spawnGarageProp(garage)
            if obj and DoesEntityExist(obj) then
                return
            end
            Wait(400 + attempt * 200)
        end
        print(('^3[ec_garage]^7 Prop konnte nicht gespawnt werden: %s'):format(garageKey(garage)))
    end)
end

local function refreshBlipsAndTargets()
    ECGarage.Target.ClearAll()

    for _, handle in pairs(blips) do
        clearBlip(handle)
    end
    blips = {}

    for _, garage in ipairs(GarageSeed or {}) do
        local pt = garage.interact
        if garage.blipEnabled ~= false and pt then
            local blip = AddBlipForCoord(pt.x, pt.y, pt.z)
            SetBlipSprite(blip, garage.blipSprite or 357)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.85)
            SetBlipColour(blip, garage.blipColor or 3)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(garage.blipLabel or garage.name)
            EndTextCommandSetBlipName(blip)
            blips[garageKey(garage)] = blip
        end

        local key = garageKey(garage)
        local prop = garage.prop
        local hasProp = prop and prop.model and prop.x and prop.enabled ~= false
        local entity = props[key]

        if hasProp then
            if entity and DoesEntityExist(entity) then
                if Config.InteractMode ~= 'marker' then
                    ECGarage.Target.Register(garage, entity)
                end
            end
        elseif Config.InteractMode ~= 'marker' and pt then
            ECGarage.Target.Register(garage, nil)
        end
    end
end

local function clearAllProps()
    for _, entity in pairs(props) do
        clearPropEntity(entity)
    end
    props = {}
end

local function refreshWorld(fullRespawnProps)
    refreshToken = refreshToken + 1
    local token = refreshToken

    if fullRespawnProps then
        clearAllProps()
    end

    refreshBlipsAndTargets()

    for _, garage in ipairs(GarageSeed or {}) do
        local prop = garage.prop
        if prop and prop.model and prop.x and prop.enabled ~= false then
            local key = garageKey(garage)
            if fullRespawnProps or not props[key] or not DoesEntityExist(props[key]) then
                if props[key] and not DoesEntityExist(props[key]) then
                    props[key] = nil
                end
                spawnGaragePropAsync(garage, token)
            end
        end
    end
end

function ECGarage.RefreshWorld()
    refreshWorld(true)
end

function ECGarage.OnGaragesSynced()
    hasSynced = true
    refreshWorld(true)
end

function ECGarage.EnsureProps()
    refreshWorld(false)
end

--- Erst DB-Sync abwarten — verhindert „Prop kurz da, dann weg“
CreateThread(function()
    Wait(2500)
    if not hasSynced then
        for _, g in ipairs(GarageSeed or {}) do
            ECGarage.MergeGarageFromTemplate(g)
        end
        refreshWorld(true)
    end
end)

--- Fehlende Props nachladen (ohne alles zu löschen)
CreateThread(function()
    while true do
        Wait(5000)
        if GarageSeed and #GarageSeed > 0 then
            ECGarage.EnsureProps()
        end
    end
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then
        return
    end
    hasSynced = false
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then
        return
    end
    refreshToken = refreshToken + 1
    for _, handle in pairs(blips) do
        clearBlip(handle)
    end
    clearAllProps()
    blips = {}
    loadedModels = {}
    ECGarage.Target.ClearAll()
end)
