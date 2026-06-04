--- Debug: Auspark-Slots als Marker (frei / belegt)

ECGarage.Client = ECGarage.Client or {}

local debugActive = Config.DebugSpawnMarkers == true

local function canUseDebug()
    if Config.DebugSpawnMarkersAdminOnly ~= false then
        return ECGarage.Client.CanManageGarages and ECGarage.Client.CanManageGarages()
    end
    return true
end

local function notify(msg)
    if GetResourceState('ox_lib') == 'started' then
        pcall(function()
            exports.ox_lib:notify({ title = 'EC Garage Debug', description = msg, type = 'inform' })
        end)
        return
    end
    TriggerEvent('chat:addMessage', { args = { 'Garage Debug', msg } })
end

local function drawText3D(coords, text)
    local onScreen, sx, sy = World3dToScreen2d(coords.x, coords.y, coords.z)
    if not onScreen then
        return
    end
    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(230, 235, 240, 230)
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry('STRING')
    AddTextComponentSubstringPlayerName(text)
    DrawText(sx, sy)
end

local function drawSpawnSlot(garage, index, slot)
    local radius = Config.SpawnSlotRadius or 4.0
    local free = ECGarage.Client.IsSpawnSlotFree(slot, radius)
    local r, g, b, a = free and 90, 210, 120, 160 or 255, 90, 90, 160

    DrawMarker(
        1,
        slot.x, slot.y, slot.z - 0.98,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        radius * 2.0, radius * 2.0, 0.35,
        r, g, b, a,
        false, false, 2, false, nil, nil, false
    )

    DrawMarker(
        2,
        slot.x, slot.y, slot.z + 0.85,
        0.0, 0.0, 0.0,
        0.0, 0.0, slot.h or 0.0,
        0.45, 0.45, 0.45,
        255, 255, 255, 200,
        false, false, 2, false, nil, nil, false
    )

    DrawMarker(
        25,
        slot.x, slot.y, slot.z + 0.05,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        0.5, 0.5, 0.5,
        r, g, b, 220,
        false, false, 2, false, nil, nil, false
    )

    local label = ('%s #%d · Slot %d · %s · %.1fm'):format(
        garage.blipLabel or garage.name or garage.id,
        index,
        index,
        free and 'FREI' or 'BELEGT',
        radius
    )
    drawText3D(vector3(slot.x, slot.y, slot.z + 1.15), label)
end

RegisterCommand('garagedebug', function()
    if not canUseDebug() then
        notify('Keine Berechtigung (admin/manager)')
        return
    end
    debugActive = not debugActive
    notify(debugActive and 'Spawn-Marker: AN' or 'Spawn-Marker: AUS')
end, false)

CreateThread(function()
    while true do
        if not debugActive or not canUseDebug() then
            Wait(800)
        else
            local sleep = 400
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local drawDist = Config.DebugSpawnDrawDistance or 80.0

            for _, garage in ipairs(GarageSeed or {}) do
                for index, slot in ipairs(garage.spawnSlots or {}) do
                    if slot.x then
                        local pos = vector3(slot.x, slot.y, slot.z)
                        local dist = #(coords - pos)
                        if dist < drawDist then
                            sleep = 0
                            drawSpawnSlot(garage, index, slot)
                        end
                    end
                end
            end

            Wait(sleep)
        end
    end
end)
