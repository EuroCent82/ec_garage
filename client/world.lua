--- Blips und Welt-Props für Garagen aus GarageSeed

local blips = {}
local props = {}

local function clearBlip(handle)
    if handle and DoesBlipExist(handle) then
        RemoveBlip(handle)
    end
end

local function clearProp(entity)
    if entity and DoesEntityExist(entity) then
        DeleteEntity(entity)
    end
end

local function refreshWorld()
    for _, handle in pairs(blips) do
        clearBlip(handle)
    end
    for _, entity in pairs(props) do
        clearProp(entity)
    end

    blips = {}
    props = {}

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
            blips[garage.id] = blip
        end

        local prop = garage.prop
        if prop and prop.enabled and prop.model and prop.x then
            local model = joaat(prop.model)
            if IsModelInCdimage(model) then
                RequestModel(model)
                local timeout = GetGameTimer() + 5000
                while not HasModelLoaded(model) and GetGameTimer() < timeout do
                    Wait(10)
                end
                if HasModelLoaded(model) then
                    local obj = CreateObject(model, prop.x, prop.y, prop.z, false, false, false)
                    SetEntityHeading(obj, prop.h or 0.0)
                    PlaceObjectOnGroundProperly(obj)
                    FreezeEntityPosition(obj, true)
                    SetEntityAsMissionEntity(obj, true, true)
                    props[garage.id] = obj
                    SetModelAsNoLongerNeeded(model)
                end
            else
                print(('^3[ec_garage]^7 Unbekanntes Prop-Modell: %s'):format(prop.model))
            end
        end
    end
end

function ECGarage.RefreshWorld()
    refreshWorld()
end

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then
        return
    end
    refreshWorld()
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then
        return
    end
    for _, handle in pairs(blips) do
        clearBlip(handle)
    end
    for _, entity in pairs(props) do
        clearProp(entity)
    end
end)
