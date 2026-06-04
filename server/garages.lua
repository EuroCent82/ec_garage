ECGarage.Server = ECGarage.Server or {}

local function decodeJson(val)
    if type(val) == 'table' then
        return val
    end
    if val == nil or val == '' then
        return nil
    end
    local ok, data = pcall(json.decode, val)
    if ok and type(data) == 'table' then
        return data
    end
    return nil
end

local function encodeJson(tbl)
    if not tbl then
        return nil
    end
    return json.encode(tbl)
end

function ECGarage.Server.CanUseCreator(source)
    return ECGarage.Bridge.CanUseCreator(source)
end

function ECGarage.Server.LoadGaragesFromDb()
    if not ECGarage.MySQL.IsReady() then
        return nil, 'no_mysql'
    end

    local rows = ECGarage.MySQL.Await('SELECT * FROM `ec_garages` WHERE `enabled` = 1 ORDER BY `name` ASC')
    if not rows then
        return nil, 'query_failed'
    end

    if #rows == 0 then
        return {}, nil
    end

    local slotRows = ECGarage.MySQL.Await(
        'SELECT `garage_id`, `slot_type`, `x`, `y`, `z`, `h`, `sort_order` FROM `ec_garage_slots` ORDER BY `garage_id`, `sort_order` ASC'
    ) or {}

    local slotsByGarage = {}
    for _, s in ipairs(slotRows) do
        local gid = s.garage_id
        slotsByGarage[gid] = slotsByGarage[gid] or {}
        slotsByGarage[gid][#slotsByGarage[gid] + 1] = s
    end

    local garages = {}
    for _, row in ipairs(rows) do
        local entry = ECGarage.Server.RowToGarage(row, slotsByGarage[row.id] or {})
        garages[#garages + 1] = entry
    end

    return garages, nil
end

function ECGarage.Server.RowToGarage(row, slotRows)
    local interact = decodeJson(row.interact)
    local propJson = decodeJson(row.prop)
    local spawnSlots = {}
    local parkSlots = {}

    for _, s in ipairs(slotRows) do
        local slot = {
            x = tonumber(s.x) or 0.0,
            y = tonumber(s.y) or 0.0,
            z = tonumber(s.z) or 0.0,
            h = tonumber(s.h) or 0.0,
        }
        if s.slot_type == 'spawn' then
            spawnSlots[#spawnSlots + 1] = slot
        elseif s.slot_type == 'park' then
            parkSlots[#parkSlots + 1] = slot
        end
    end

    local entry = {
        id = tostring(row.id),
        name = row.name,
        type = row.type or 'land',
        interact = interact,
        spawnSlots = spawnSlots,
        parkMode = row.park_mode or 'zone',
        parkRadius = tonumber(row.park_radius) or 25,
        parkSlots = parkSlots,
        blipEnabled = tonumber(row.blip_enabled) ~= 0,
        blipLabel = row.blip_label or row.name,
        blipSprite = tonumber(row.blip_sprite) or 357,
        blipColor = tonumber(row.blip_color) or 3,
        job = row.job or '',
        minGrade = tonumber(row.min_grade) or 0,
        prop = nil,
    }

    if propJson and propJson.model and propJson.enabled ~= false then
        entry.prop = {
            enabled = true,
            model = propJson.model,
            x = tonumber(propJson.x) or 0.0,
            y = tonumber(propJson.y) or 0.0,
            z = tonumber(propJson.z) or 0.0,
            h = tonumber(propJson.h) or 0.0,
        }
    end

    return ECGarage.MergeGarageFromTemplate(entry)
end

function ECGarage.Server.ReplaceGarageSeed(entries)
    GarageSeed = {}
    for _, entry in ipairs(entries or {}) do
        GarageSeed[#GarageSeed + 1] = entry
    end
end

function ECGarage.Server.BroadcastGarageSync()
    TriggerClientEvent('ec_garage:syncGarages', -1, ECGarage.GetGaragesForNui())
end

function ECGarage.Server.SaveGarageToDb(data, createdBy)
    if not ECGarage.MySQL.IsReady() then
        return false, 'Kein MySQL (oxmysql) aktiv'
    end

    if not data or not data.id or not data.name or not data.interact then
        return false, 'Ungültige Garagen-Daten'
    end

    local id = tostring(data.id):sub(1, 64)
    local interact = data.interact
    if type(interact) ~= 'table' or not interact.x then
        return false, 'Interaktionspunkt fehlt'
    end

    local propJson = nil
    if data.prop and data.prop.model and data.prop.enabled ~= false then
        propJson = {
            enabled = true,
            model = data.prop.model,
            x = data.prop.x,
            y = data.prop.y,
            z = data.prop.z,
            h = data.prop.h or 0.0,
        }
    end

    local parkMode = data.parkMode == 'slot' and 'slot' or 'zone'

    ECGarage.MySQL.Await([[
        INSERT INTO `ec_garages` (
            `id`, `name`, `type`, `interact`, `park_mode`, `park_radius`,
            `blip_enabled`, `blip_sprite`, `blip_color`, `blip_label`,
            `job`, `min_grade`, `prop`, `enabled`, `created_by`
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?)
        ON DUPLICATE KEY UPDATE
            `name` = VALUES(`name`),
            `type` = VALUES(`type`),
            `interact` = VALUES(`interact`),
            `park_mode` = VALUES(`park_mode`),
            `park_radius` = VALUES(`park_radius`),
            `blip_enabled` = VALUES(`blip_enabled`),
            `blip_sprite` = VALUES(`blip_sprite`),
            `blip_color` = VALUES(`blip_color`),
            `blip_label` = VALUES(`blip_label`),
            `job` = VALUES(`job`),
            `min_grade` = VALUES(`min_grade`),
            `prop` = VALUES(`prop`),
            `enabled` = 1,
            `updated_at` = CURRENT_TIMESTAMP
    ]], {
        id,
        data.name,
        data.type or 'land',
        encodeJson(interact),
        parkMode,
        tonumber(data.parkRadius) or 25,
        data.blipEnabled ~= false and 1 or 0,
        tonumber(data.blipSprite) or 357,
        tonumber(data.blipColor) or 3,
        data.blipLabel or data.name,
        (data.job and data.job ~= '') and data.job or nil,
        tonumber(data.minGrade) or 0,
        encodeJson(propJson),
        createdBy,
    })

    ECGarage.MySQL.Await('DELETE FROM `ec_garage_slots` WHERE `garage_id` = ?', { id })

    local spawnSlots = data.spawnSlots or {}
    for i, slot in ipairs(spawnSlots) do
        ECGarage.MySQL.Await(
            'INSERT INTO `ec_garage_slots` (`garage_id`, `slot_type`, `x`, `y`, `z`, `h`, `sort_order`) VALUES (?, ?, ?, ?, ?, ?, ?)',
            { id, 'spawn', slot.x, slot.y, slot.z, slot.h or 0.0, i }
        )
    end

    if parkMode == 'slot' then
        local parkSlots = data.parkSlots or {}
        for i, slot in ipairs(parkSlots) do
            ECGarage.MySQL.Await(
                'INSERT INTO `ec_garage_slots` (`garage_id`, `slot_type`, `x`, `y`, `z`, `h`, `sort_order`) VALUES (?, ?, ?, ?, ?, ?, ?)',
                { id, 'park', slot.x, slot.y, slot.z, slot.h or 0.0, i }
            )
        end
    end

    return true, nil
end

function ECGarage.Server.InitGaragesFromDatabase()
    if Config.UseDatabaseGarages == false then
        print('^3[ec_garage]^7 Garagen-DB deaktiviert — nutze config/garages.lua (GarageSeed).')
        return
    end

    local garages, err = ECGarage.Server.LoadGaragesFromDb()
    if err == 'no_mysql' then
        print('^3[ec_garage]^7 Kein MySQL — Garagen aus config/garages.lua (GarageSeed).')
        return
    end

    if not garages then
        print('^1[ec_garage]^7 Garagen konnten nicht geladen werden.')
        return
    end

    if #garages > 0 then
        ECGarage.Server.ReplaceGarageSeed(garages)
        print(('^2[ec_garage]^7 %d Garage(n) aus der Datenbank geladen.'):format(#garages))
    else
        print('^3[ec_garage]^7 Keine Garagen in ec_garages — nutze GarageSeed aus config.')
    end
end

RegisterNetEvent('ec_garage:requestGarageSync', function()
    local src = source
    TriggerClientEvent('ec_garage:syncGarages', src, ECGarage.GetGaragesForNui())
end)

RegisterNetEvent('ec_garage:requestGarageList', function()
    local src = source
    if not ECGarage.Server.CanUseCreator(src) then
        TriggerClientEvent('ec_garage:creatorDenied', src)
        return
    end
    TriggerClientEvent('ec_garage:openCreator', src, ECGarage.GetGaragesForNui())
end)

function ECGarage.Server.DeleteGarageFromDb(garageId)
    if not ECGarage.MySQL.IsReady() then
        return false, 'Kein MySQL aktiv'
    end

    local id = tostring(garageId)
    ECGarage.MySQL.Await('DELETE FROM `ec_garage_slots` WHERE `garage_id` = ?', { id })
    ECGarage.MySQL.Await('DELETE FROM `ec_garages` WHERE `id` = ?', { id })
    return true, nil
end

function ECGarage.Server.RemoveGarageFromSeed(garageId)
    local key = tostring(garageId)
    local idx = ECGarage.FindGarageIndex(key)
    if idx then
        table.remove(GarageSeed, idx)
        return true
    end
    return false
end

RegisterNetEvent('ec_garage:deleteGarage', function(garageId)
    local src = source

    if not ECGarage.Server.CanUseCreator(src) then
        TriggerClientEvent('ec_garage:deleteGarageResult', src, false, 'Keine Berechtigung')
        return
    end

    if not garageId then
        TriggerClientEvent('ec_garage:deleteGarageResult', src, false, 'Garagen-ID fehlt')
        return
    end

    local id = tostring(garageId)
    for _, protected in ipairs(Config.ProtectedGarageIds or {}) do
        if tostring(protected) == id then
            TriggerClientEvent('ec_garage:deleteGarageResult', src, false, 'Diese Garage ist geschützt')
            return
        end
    end

    local okDb, errMsg = ECGarage.Server.DeleteGarageFromDb(id)
    if not okDb then
        TriggerClientEvent('ec_garage:deleteGarageResult', src, false, errMsg or 'DB-Fehler')
        return
    end

    ECGarage.Server.RemoveGarageFromSeed(id)
    ECGarage.Server.BroadcastGarageSync()
    TriggerClientEvent('ec_garage:deleteGarageResult', src, true, 'Garage gelöscht')
    print(('^2[ec_garage]^7 Garage gelöscht: %s'):format(id))
end)

RegisterNetEvent('ec_garage:saveGarage', function(data)
    local src = source

    if not ECGarage.Server.CanUseCreator(src) then
        TriggerClientEvent('ec_garage:saveGarageResult', src, false, 'Keine Berechtigung')
        return
    end

    if not data or type(data) ~= 'table' then
        TriggerClientEvent('ec_garage:saveGarageResult', src, false, 'Ungültige Daten')
        return
    end

    data.id = tostring(data.id or ''):sub(1, 64)
    if data.id == '' then
        TriggerClientEvent('ec_garage:saveGarageResult', src, false, 'Garagen-ID fehlt')
        return
    end

    local identifier = ECGarage.Bridge.GetIdentifier(src) or ('src:%s'):format(src)
    local okDb, errMsg = ECGarage.Server.SaveGarageToDb(data, identifier)

    if not okDb then
        TriggerClientEvent('ec_garage:saveGarageResult', src, false, errMsg or 'DB-Fehler')
        return
    end

    if not ECGarage.ApplyGarageFromNui(data) then
        TriggerClientEvent('ec_garage:saveGarageResult', src, false, 'Speichern fehlgeschlagen')
        return
    end

    ECGarage.Server.BroadcastGarageSync()
    TriggerClientEvent('ec_garage:saveGarageResult', src, true, data.name or data.id)
    print(('^2[ec_garage]^7 Garage gespeichert (DB + Live): %s [%s]'):format(data.name or '?', data.id))
end)

CreateThread(function()
    Wait(800)
    ECGarage.Server.InitGaragesFromDatabase()
    Wait(200)
    ECGarage.Server.BroadcastGarageSync()
end)
