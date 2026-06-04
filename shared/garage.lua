--- Garagen-Daten für Client + NUI (GarageSeed / später DB)

function ECGarage.GarageToNui(g)
    local prop = g.prop
    local propNui = nil
    if prop and prop.enabled and prop.model then
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
    for i, g in ipairs(GarageSeed or {}) do
        if g.id == id then
            return i
        end
    end
    return nil
end

function ECGarage.ApplyGarageFromNui(data)
    if not data or not data.id then
        return false
    end

    local entry = {
        id = data.id,
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

    local idx = ECGarage.FindGarageIndex(data.id)
    if idx then
        GarageSeed[idx] = entry
    else
        GarageSeed[#GarageSeed + 1] = entry
    end

    return true
end
