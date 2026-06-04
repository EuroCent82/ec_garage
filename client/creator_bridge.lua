--- Creator: Spieler-Position, Speichern (Server → DB → Live-Sync)

local placementActive = false
local saveCallback = nil

local function playerCoords()
    local ped = PlayerPedId()
    local c = GetEntityCoords(ped)
    return {
        x = math.floor(c.x * 100) / 100,
        y = math.floor(c.y * 100) / 100,
        z = math.floor(c.z * 100) / 100,
        h = math.floor(GetEntityHeading(ped) * 10) / 10,
    }
end

RegisterNUICallback('getCoords', function(_, cb)
    cb(playerCoords())
end)

RegisterNUICallback('setPlacementActive', function(data, cb)
    placementActive = data.active == true
    cb('ok')
end)

RegisterNUICallback('saveGarage', function(data, cb)
    saveCallback = cb
    TriggerServerEvent('ec_garage:saveGarage', data)
end)

RegisterNetEvent('ec_garage:saveGarageResult', function(ok, message)
    if saveCallback then
        saveCallback({ ok = ok == true, message = message })
        saveCallback = nil
    end
    if ok then
        SendNUIMessage({
            action = 'garagesSynced',
            garages = ECGarage.GetGaragesForNui(),
        })
    end
end)

RegisterNetEvent('ec_garage:syncGarages', function(nuiList)
    ECGarage.SyncGarageSeedFromNui(nuiList)
    ECGarage.OnGaragesSynced()
    if ECGarage.Client.RefreshCanManage then
        ECGarage.Client.RefreshCanManage()
    end
    SendNUIMessage({
        action = 'garagesSynced',
        garages = nuiList or ECGarage.GetGaragesForNui(),
    })
end)

RegisterNetEvent('ec_garage:creatorDenied', function()
    local msg = 'Keine Berechtigung für /creategarage (Gruppe admin/manager oder ACE).'
    print(('^1[ec_garage]^7 %s'):format(msg))
    TriggerEvent('chat:addMessage', {
        color = { 255, 120, 120 },
        multiline = false,
        args = { 'Garage', msg },
    })
end)

CreateThread(function()
    while true do
        if placementActive then
            SendNUIMessage({
                action = 'placementSync',
                position = playerCoords(),
            })
            Wait(150)
        else
            Wait(400)
        end
    end
end)

CreateThread(function()
    Wait(500)
    TriggerServerEvent('ec_garage:requestGarageSync')
end)
