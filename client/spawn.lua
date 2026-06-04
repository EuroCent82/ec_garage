--- Ausparken: freien Spawn-Slot finden & Fahrzeug spawnen (ESX)

ECGarage.Client = ECGarage.Client or {}

local pendingGarageId = nil

function ECGarage.Client.IsSpawnSlotFree(slot, radius)
    radius = radius or Config.SpawnSlotRadius or 4.0
    if not slot or not slot.x then
        return false
    end

    local pos = vector3(slot.x + 0.0, slot.y + 0.0, slot.z + 0.0)
    local vehicles = GetGamePool('CVehicle')

    for i = 1, #vehicles do
        local veh = vehicles[i]
        if DoesEntityExist(veh) then
            local vehCoords = GetEntityCoords(veh)
            if #(vehCoords - pos) < radius then
                return false
            end
        end
    end

    return true
end

function ECGarage.Client.FindFreeSpawnSlot(garage)
    if not garage or not garage.spawnSlots then
        return nil, nil
    end

    for index, slot in ipairs(garage.spawnSlots) do
        if ECGarage.Client.IsSpawnSlotFree(slot) then
            return index, slot
        end
    end

    return nil, nil
end

local function resolveModelHash(props)
    local model = props and (props.model or props.hash)
    if not model then
        return nil
    end
    if type(model) == 'number' then
        return model
    end
    if type(model) == 'string' then
        local num = tonumber(model)
        if num then
            return num
        end
        return joaat(model)
    end
    return nil
end

function ECGarage.Client.SpawnOwnedVehicle(data)
    if not data or not data.slot or not data.props then
        return false, 'Ungültige Spawn-Daten'
    end

    local slot = data.slot
    local props = data.props
    local hash = resolveModelHash(props)

    if not hash or not IsModelInCdimage(hash) then
        return false, 'Fahrzeugmodell ungültig'
    end

    RequestModel(hash)
    local timeout = GetGameTimer() + 8000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(50)
    end

    if not HasModelLoaded(hash) then
        return false, 'Modell konnte nicht geladen werden'
    end

    local x, y, z = slot.x + 0.0, slot.y + 0.0, slot.z + 0.0
    local heading = slot.h or 0.0

    local veh = CreateVehicle(hash, x, y, z, heading, true, false)
    if not veh or veh == 0 then
        SetModelAsNoLongerNeeded(hash)
        return false, 'Fahrzeug-Spawn fehlgeschlagen'
    end

    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleOnGroundProperly(veh)
    SetEntityHeading(veh, heading)

    if data.plate then
        SetVehicleNumberPlateText(veh, data.plate)
    end

    if GetResourceState('es_extended') == 'started' then
        local ok, ESX = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok and ESX and ESX.Game and ESX.Game.SetVehicleProperties then
            ESX.Game.SetVehicleProperties(veh, props)
        end
    end

    if props.fuelLevel and GetResourceState('LegacyFuel') == 'started' then
        pcall(function()
            exports.LegacyFuel:SetFuel(veh, props.fuelLevel)
        end)
    end

    if Config.SpawnWarpIntoVehicle ~= false then
        local ped = PlayerPedId()
        TaskWarpPedIntoVehicle(ped, veh, -1)
    end

    SetModelAsNoLongerNeeded(hash)
    return true, nil
end

RegisterNUICallback('spawnVehicle', function(data, cb)
    local garageId = data and data.garageId
    local plate = data and data.plate

    if not garageId or not plate then
        cb({ ok = false, message = 'Garage oder Kennzeichen fehlt' })
        return
    end

    local garage = ECGarage.FindGarageById(garageId)
    if not garage then
        cb({ ok = false, message = 'Garage nicht gefunden' })
        return
    end

    if not garage.spawnSlots or #garage.spawnSlots == 0 then
        cb({ ok = false, message = 'Keine Auspark-Slots definiert' })
        return
    end

    local slotIndex, slot = ECGarage.Client.FindFreeSpawnSlot(garage)
    if not slot then
        cb({ ok = false, message = 'Kein freier Ausparkplatz — alle Slots belegt' })
        return
    end

    pendingGarageId = garageId
    TriggerServerEvent('ec_garage:takeOutVehicle', garageId, plate, slotIndex)
    cb({ ok = true, pending = true })
end)

RegisterNetEvent('ec_garage:takeOutResult', function(result)
    result = result or {}
    pendingGarageId = nil

    if result.ok then
        local okSpawn, err = ECGarage.Client.SpawnOwnedVehicle(result)
        if not okSpawn then
            result.ok = false
            result.message = err or 'Spawn fehlgeschlagen'
        end
    end

    SendNUIMessage({
        action = 'takeOutResult',
        ok = result.ok == true,
        message = result.message,
        plate = result.plate,
        garageId = result.garageId,
    })

    if result.ok and ECGarage.UI.IsOpen() then
        ECGarage.UI.Close()
    end
end)
