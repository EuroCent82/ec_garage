--- Creator: Spieler-Position + Speichern

local placementActive = false

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
    if ECGarage.ApplyGarageFromNui(data) then
        ECGarage.RefreshWorld()
        print(('^2[ec_garage]^7 Garage gespeichert: %s'):format(data.name or data.id))
        cb({ ok = true })
    else
        cb({ ok = false })
    end
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
