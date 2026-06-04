--- Garagen-Interaktion (Seed / später DB)

local interactDist = 2.0
local markerDist = 18.0

local function showHelp(text)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

CreateThread(function()
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
                            showHelp('Drücke ~INPUT_CONTEXT~ für ~b~' .. garage.name .. '~s~')
                            if IsControlJustReleased(0, 38) then
                                ECGarage.UI.OpenGarage({
                                    mode = garage.type or 'land',
                                    garageName = garage.name,
                                    garageId = garage.id,
                                })
                            end
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)
