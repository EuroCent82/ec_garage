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
    elseif entry.system == 'qb-target' then
        if entry.entity and DoesEntityExist(entry.entity) then
            pcall(function()
                exports['qb-target']:RemoveTargetEntity(entry.entity)
            end)
        end
        if entry.zoneId then
            pcall(function()
                exports['qb-target']:RemoveZone(entry.zoneId)
            end)
        end
    end
end

function ECGarage.Target.ClearAll()
    for id, entry in pairs(registered) do
        clearEntry(entry)
        registered[id] = nil
    end
end

local function buildTargetOptions(garage)
    local id = tostring(garage.id)
    local label = Config.TargetLabel or garage.name or 'Garage öffnen'
    local distance = Config.TargetDistance or 2.5
    local colors = Config.TargetAdminColors or {}

    local options = {
        {
            name = ('ec_garage_open_%s'):format(id),
            icon = 'fa-solid fa-square-parking',
            label = label,
            distance = distance,
            onSelect = function()
                ECGarage.Client.OpenGarageAt(garage)
            end,
        },
    }

    if ECGarage.Client.CanManageGarages and ECGarage.Client.CanManageGarages() then
        options[#options + 1] = {
            name = ('ec_garage_edit_%s'):format(id),
            icon = 'fa-solid fa-pen-to-square',
            label = '┃ Garage bearbeiten',
            distance = distance,
            iconColor = colors.edit or '#d8a15c',
            onSelect = function()
                ECGarage.Client.EditGarage(garage)
            end,
        }
        options[#options + 1] = {
            name = ('ec_garage_delete_%s'):format(id),
            icon = 'fa-solid fa-trash-can',
            label = '┃ Garage löschen',
            distance = distance,
            iconColor = colors.delete or '#ff7b72',
            onSelect = function()
                ECGarage.Client.DeleteGarage(garage)
            end,
        }
    end

    return options
end

local function buildQbOptions(garage)
    local label = Config.TargetLabel or garage.name or 'Garage öffnen'
    local colors = Config.TargetAdminColors or {}
    local options = {
        {
            type = 'client',
            icon = 'fas fa-square-parking',
            label = label,
            action = function()
                ECGarage.Client.OpenGarageAt(garage)
            end,
        },
    }

    if ECGarage.Client.CanManageGarages and ECGarage.Client.CanManageGarages() then
        options[#options + 1] = {
            type = 'client',
            icon = 'fas fa-pen-to-square',
            label = ('%s Garage bearbeiten'):format(colors.edit and '🟠' or ''),
            action = function()
                ECGarage.Client.EditGarage(garage)
            end,
        }
        options[#options + 1] = {
            type = 'client',
            icon = 'fas fa-trash-can',
            label = ('%s Garage löschen'):format(colors.delete and '🔴' or ''),
            action = function()
                ECGarage.Client.DeleteGarage(garage)
            end,
        }
    end

    return options
end

function ECGarage.Target.Register(garage, entity)
    ECGarage.Target.ClearEntry(garage.id)

    local system = resolveTargetSystem()
    if not system then
        return false
    end

    local garageId = tostring(garage.id)
    local distance = Config.TargetDistance or 2.5

    if system == 'ox_target' then
        local options = buildTargetOptions(garage)

        if entity and DoesEntityExist(entity) then
            exports.ox_target:addLocalEntity(entity, options)
            registered[garageId] = { system = system, entity = entity }
            return true
        end

        local pt = garage.interact
        if pt then
            local zoneId = exports.ox_target:addSphereZone({
                coords = vec3(pt.x, pt.y, pt.z),
                radius = distance,
                debug = false,
                options = options,
            })
            registered[garageId] = { system = system, zoneId = zoneId }
            return true
        end
    elseif system == 'qb-target' then
        local qbOptions = buildQbOptions(garage)

        if entity and DoesEntityExist(entity) then
            exports['qb-target']:AddTargetEntity(entity, {
                options = qbOptions,
                distance = distance,
            })
            registered[garageId] = { system = system, entity = entity }
            return true
        end

        local pt = garage.interact
        if pt then
            local zoneName = ('ec_garage_%s'):format(garageId)
            exports['qb-target']:AddCircleZone(zoneName, vector3(pt.x, pt.y, pt.z), distance, {
                name = zoneName,
                useZ = true,
                debugPoly = false,
            }, {
                options = qbOptions,
                distance = distance,
            })
            registered[garageId] = { system = system, zoneId = zoneName }
            return true
        end
    end

    return false
end

function ECGarage.Target.ClearEntry(garageId)
    local entry = registered[tostring(garageId)]
    if entry then
        clearEntry(entry)
        registered[tostring(garageId)] = nil
    end
end
