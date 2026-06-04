--- Garagen öffnen (Target am Prop / optional Marker)

function ECGarage.Client.OpenGarageAt(garage)
    if not garage or ECGarage.UI.IsOpen() then
        return
    end

    TriggerServerEvent('ec_garage:requestVehicles', garage.id, garage.type or 'land')
end

RegisterNetEvent('ec_garage:receiveVehicles', function(garageId, vehicles)
    local garage = ECGarage.FindGarageById(garageId)
    if not garage then
        return
    end

    ECGarage.UI.OpenGarage({
        mode = garage.type or 'land',
        garageName = garage.name,
        garageId = tostring(garage.id),
        vehicles = vehicles or {},
    })
end)

local function showHelp(text)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

CreateThread(function()
    if Config.InteractMode == 'target' then
        return
    end

    local interactDist = 2.0
    local markerDist = 18.0

    while true do
        local sleep = 800
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        if not ECGarage.UI.IsOpen() and GarageSeed then
            for _, garage in ipairs(GarageSeed) do
                local pt = garage.interact
                if pt then
                    local dist = #(coords - vector3(pt.x, pt.y, pt.z))
                    if dist < markerDist then
                        sleep = 0
                        DrawMarker(
                            1, pt.x, pt.y, pt.z - 1.0,
                            0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                            1.2, 1.2, 0.5,
                            59, 130, 246, 120,
                            false, false, 2, false, nil, nil, false
                        )
                        if dist < interactDist then
                            showHelp('Drücke ~INPUT_CONTEXT~ für ~b~' .. (garage.blipLabel or garage.name) .. '~s~')
                            if IsControlJustReleased(0, 38) then
                                ECGarage.Client.OpenGarageAt(garage)
                            end
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)
