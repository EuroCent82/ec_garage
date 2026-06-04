--- Garagen-Daten für Client + NUI (GarageSeed / später DB)

function ECGarage.FindConfigTemplate(id)
    local key = id ~= nil and tostring(id) or ''
    for _, g in ipairs(GarageConfigTemplate or {}) do
        if tostring(g.id) == key then
            return g
        end
    end
    return nil
end

local function copyProp(prop)
    if not prop or not prop.model then
        return nil
    end
    return {
        enabled = prop.enabled ~= false,
        model = prop.model,
        x = prop.x,
        y = prop.y,
        z = prop.z,
        h = prop.h or 0.0,
    }
end

function ECGarage.MergeGarageFromTemplate(entry)
    if Config.MergeGarageTemplate == false or not entry then
        return entry
    end

    local cfg = ECGarage.FindConfigTemplate(entry.id)
    if not cfg then
        return entry
    end

    if (not entry.prop or not entry.prop.model) and cfg.prop and cfg.prop.model then
        entry.prop = copyProp(cfg.prop)
    end

    if not entry.interact and cfg.interact then
        entry.interact = cfg.interact
    end

    if not entry.spawnSlots or #entry.spawnSlots == 0 then
        entry.spawnSlots = cfg.spawnSlots or {}
    end

    return entry
end

function ECGarage.FindGarageById(id)
    local key = id ~= nil and tostring(id) or ''
    for _, garage in ipairs(GarageSeed or {}) do
        if tostring(garage.id) == key then
            return garage
        end
    end
    return nil
end

function ECGarage.GarageToNui(g)
    local prop = g.prop
    local propNui = nil
    if prop and prop.model and prop.enabled ~= false then
        propNui = {
            enabled = true,
            model = prop.model,
            x = prop.x,
            y = prop.y,
            z = prop.z,
            h = prop.h or 0.0,
        }
    end

    return {
        id = g.id,
        name = g.name,
        type = g.type or 'land',
        interact = g.interact,
        spawnSlots = g.spawnSlots or {},
        parkMode = g.parkMode or 'zone',
        parkRadius = g.parkRadius or 25,
        parkSlots = g.parkSlots or {},
        blipEnabled = g.blipEnabled ~= false,
        blipLabel = g.blipLabel or g.name,
        blipSprite = g.blipSprite or 357,
        blipColor = g.blipColor or 3,
        job = g.job or '',
        minGrade = g.minGrade or 0,
        prop = propNui,
    }
end

function ECGarage.GetGaragesForNui()
    local list = {}
    for _, g in ipairs(GarageSeed or {}) do
        list[#list + 1] = ECGarage.GarageToNui(g)
    end
    return list
end

function ECGarage.FindGarageIndex(id)
    local key = id ~= nil and tostring(id) or ''
    for i, g in ipairs(GarageSeed or {}) do
        if tostring(g.id) == key then
            return i
        end
    end
    return nil
end

function ECGarage.SyncGarageSeedFromNui(list)
    GarageSeed = {}
    for _, data in ipairs(list or {}) do
        ECGarage.ApplyGarageFromNui(data)
    end
end

function ECGarage.ApplyGarageFromNui(data)
    if not data or not data.id then
        return false
    end

    local entry = {
        id = tostring(data.id),
        name = data.name,
        type = data.type or 'land',
        interact = data.interact,
        spawnSlots = data.spawnSlots or {},
        parkMode = data.parkMode or 'zone',
        parkRadius = data.parkRadius or 25,
        parkSlots = data.parkSlots or {},
        blipEnabled = data.blipEnabled ~= false,
        blipLabel = data.blipLabel or data.name,
        blipSprite = data.blipSprite or 357,
        blipColor = data.blipColor or 3,
        job = data.job or '',
        minGrade = data.minGrade or 0,
        prop = nil,
    }

    if data.prop and data.prop.model and (data.prop.enabled ~= false) then
        entry.prop = {
            enabled = true,
            model = data.prop.model,
            x = data.prop.x,
            y = data.prop.y,
            z = data.prop.z,
            h = data.prop.h or 0.0,
        }
    end

    entry = ECGarage.MergeGarageFromTemplate(entry)

    local idx = ECGarage.FindGarageIndex(data.id)
    if idx then
        GarageSeed[idx] = entry
    else
        GarageSeed[#GarageSeed + 1] = entry
    end

    return true
end
