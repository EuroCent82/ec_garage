ECGarage.Target = ECGarage.Target or {}

local registered = {}

local function resolveTargetSystem()
    local mode = Config.Target or 'auto'
    if mode == 'none' then
        return nil
    end
    if mode == 'auto' then
        if GetResourceState('ox_target') == 'started' then
            return 'ox_target'
        end
        if GetResourceState('qb-target') == 'started' then
            return 'qb-target'
        end
        return nil
    end
    if GetResourceState(mode) == 'started' then
        return mode
    end
    return nil
end

local function clearEntry(entry)
    if not entry then
        return
    end

    if entry.system == 'ox_target' then
        if entry.entity and DoesEntityExist(entry.entity) then
            pcall(function()
                exports.ox_target:removeLocalEntity(entry.entity)
            end)
        end
        if entry.zoneId then
            pcall(function()
                exports.ox_target:removeZone(entry.zoneId)
            end)
        end
    elseif entry.system == 'qb-target' and entry.entity and DoesEntityExist(entry.entity) then
        pcall(function()
            exports['qb-target']:RemoveTargetEntity(entry.entity)
        end)
    end
end

function ECGarage.Target.ClearAll()
    for id, entry in pairs(registered) do
        clearEntry(entry)
        registered[id] = nil
    end
end

function ECGarage.Target.Register(garage, entity)
    ECGarage.Target.ClearEntry(garage.id)

    local system = resolveTargetSystem()
    if not system then
        return false
    end

    local label = Config.TargetLabel or garage.name or 'Garage öffnen'
    local distance = Config.TargetDistance or 2.5

    local function onSelect()
        ECGarage.Client.OpenGarageAt(garage)
    end

    if system == 'ox_target' then
        if entity and DoesEntityExist(entity) then
            exports.ox_target:addLocalEntity(entity, {
                {
                    name = ('ec_garage_%s'):format(garage.id),
                    icon = 'fa-solid fa-square-parking',
                    label = label,
                    distance = distance,
                    onSelect = onSelect,
                },
            })
            registered[garage.id] = { system = system, entity = entity }
            return true
        end

        local pt = garage.interact
        if pt then
            local zoneId = exports.ox_target:addSphereZone({
                coords = vec3(pt.x, pt.y, pt.z),
                radius = distance,
                debug = false,
                options = {
                    {
                        name = ('ec_garage_zone_%s'):format(garage.id),
                        icon = 'fa-solid fa-square-parking',
                        label = label,
                        onSelect = onSelect,
                    },
                },
            })
            registered[garage.id] = { system = system, zoneId = zoneId }
            return true
        end
    elseif system == 'qb-target' and entity and DoesEntityExist(entity) then
        exports['qb-target']:AddTargetEntity(entity, {
            options = {
                {
                    type = 'client',
                    icon = 'fas fa-square-parking',
                    label = label,
                    action = onSelect,
                },
            },
            distance = distance,
        })
        registered[garage.id] = { system = system, entity = entity }
        return true
    end

    return false
end

function ECGarage.Target.ClearEntry(garageId)
    local entry = registered[garageId]
    if entry then
        clearEntry(entry)
        registered[garageId] = nil
    end
end
