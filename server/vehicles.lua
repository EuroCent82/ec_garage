ECGarage.Server = ECGarage.Server or {}

local ESX_TYPE_TO_CATEGORY = {
    car = 'land',
    aircraft = 'air',
    plane = 'air',
    helicopter = 'air',
    heli = 'air',
    boat = 'water',
}

local function normalizeParking(value)
    if value == nil then
        return ''
    end
    return tostring(value):gsub('^%s+', ''):gsub('%s+$', ''):lower()
end

local function vehicleCategory(row, garageType)
    local t = row.type and string.lower(tostring(row.type)) or 'car'
    return ESX_TYPE_TO_CATEGORY[t] or 'land'
end

local function decodeVehicleProps(raw)
    if not raw or raw == '' then
        return {}
    end
    local ok, data = pcall(json.decode, raw)
    if ok and type(data) == 'table' then
        return data
    end
    return {}
end

local function healthPercent(value, max)
    max = max or 1000.0
    if not value then
        return 100
    end
    return math.max(0, math.min(100, math.floor((tonumber(value) / max) * 100)))
end

local function modelLabel(props, rowType)
    if props.displayName and props.displayName ~= '' then
        return tostring(props.displayName)
    end
    if props.label and props.label ~= '' then
        return tostring(props.label)
    end
    local model = props.model or props.hash
    if model then
        return ('Fahrzeug (%s)'):format(tostring(model))
    end
    return rowType == 'boat' and 'Boot' or (rowType == 'aircraft' and 'Luftfahrzeug' or 'Fahrzeug')
end

local function rowToNui(row, meta, garageType)
    local props = decodeVehicleProps(row.vehicle)
    local category = vehicleCategory(row, garageType)
    local stored = tonumber(row.stored) == 1
    local pound = row.pound
    local hasPound = pound ~= nil and tostring(pound) ~= '' and tostring(pound):lower() ~= 'null'

    local status = 'out'
    if hasPound then
        status = 'impound'
    elseif stored then
        status = 'parked'
    end

    local vehicle = {
        id = row.plate,
        category = category,
        plate = row.plate,
        model = modelLabel(props, row.type),
        modelKey = tostring(props.model or ''),
        customName = meta and meta.custom_name or nil,
        note = meta and meta.note or '',
        status = status,
        favorite = meta and tonumber(meta.favorite) == 1 or false,
        fuel = math.floor(tonumber(props.fuelLevel) or 100),
        body = healthPercent(props.bodyHealth),
        engine = healthPercent(props.engineHealth),
        mileage = math.floor(tonumber(row.mileage) or 0),
    }

    if status == 'impound' then
        vehicle.impoundLot = tostring(pound)
        vehicle.impoundLotName = tostring(pound)
        vehicle.impoundFee = 0
    end

    return vehicle
end

function ECGarage.Server.FetchVehicles(source, garageId, garageType)
    if not ECGarage.MySQL.IsReady() then
        print('^3[ec_garage]^7 Kein MySQL — Fahrzeugliste leer.')
        return {}
    end

    local identifier = ECGarage.Bridge.GetIdentifier(source)
    if not identifier then
        return {}
    end

    local fw = ECGarage.Bridge.Framework
    if fw ~= 'esx' then
        print('^3[ec_garage]^7 Fahrzeug-DB aktuell nur für ESX implementiert.')
        return {}
    end

    local tableName = Config.VehicleTables.esx or 'owned_vehicles'
    local parkingCol = Config.EsxParkingColumn or 'parking'
    local storedCol = Config.EsxStoredColumn or 'stored'
    local poundCol = Config.EsxPoundColumn or 'pound'
    local garageKey = normalizeParking(garageId)

    local query = ([[
        SELECT ov.plate, ov.vehicle, ov.type, ov.%s AS stored, ov.%s AS parking, ov.%s AS pound, ov.mileage,
               m.custom_name, m.note, m.favorite
        FROM `%s` ov
        LEFT JOIN `ec_garage_vehicle_meta` m ON m.plate = ov.plate
        WHERE ov.owner = ?
    ]]):format(storedCol, parkingCol, poundCol, tableName)

    local rows = ECGarage.MySQL.Await(query, { identifier })
    if not rows or #rows == 0 then
        return {}
    end

    local list = {}
    for _, row in ipairs(rows) do
        local parking = normalizeParking(row.parking)
        if parking ~= garageKey then
            goto continue
        end

        local vehicle = rowToNui(row, row, garageType)
        if vehicle.category ~= (garageType or 'land') then
            goto continue
        end

        if vehicle.status == 'impound' then
            goto continue
        end

        list[#list + 1] = vehicle
        ::continue::
    end

    return list
end

RegisterNetEvent('ec_garage:requestVehicles', function(garageId, garageType)
    local src = source
    local vehicles = ECGarage.Server.FetchVehicles(src, garageId, garageType or 'land')
    TriggerClientEvent('ec_garage:receiveVehicles', src, garageId, vehicles)
end)

function ECGarage.Server.TakeOutVehicle(source, garageId, plate, slotIndex)
    if not ECGarage.MySQL.IsReady() then
        return { ok = false, message = 'Kein MySQL aktiv' }
    end

    local garage = ECGarage.FindGarageById(garageId)
    if not garage then
        return { ok = false, message = 'Garage nicht gefunden' }
    end

    local slot = garage.spawnSlots and garage.spawnSlots[slotIndex]
    if not slot then
        return { ok = false, message = 'Ungültiger Auspark-Slot' }
    end

    local identifier = ECGarage.Bridge.GetIdentifier(source)
    if not identifier then
        return { ok = false, message = 'Spieler nicht gefunden' }
    end

    if ECGarage.Bridge.Framework ~= 'esx' then
        return { ok = false, message = 'Ausparken aktuell nur für ESX' }
    end

    local tableName = Config.VehicleTables.esx or 'owned_vehicles'
    local parkingCol = Config.EsxParkingColumn or 'parking'
    local storedCol = Config.EsxStoredColumn or 'stored'
    local garageKey = normalizeParking(garageId)
    local plateKey = tostring(plate):gsub('^%s+', ''):gsub('%s+$', '')

    local query = ([[
        SELECT plate, vehicle, type, %s AS stored, %s AS parking
        FROM `%s`
        WHERE owner = ? AND REPLACE(plate, ' ', '') = REPLACE(?, ' ', '')
        LIMIT 1
    ]]):format(storedCol, parkingCol, tableName)

    local rows = ECGarage.MySQL.Await(query, { identifier, plateKey })
    if not rows or not rows[1] then
        return { ok = false, message = 'Fahrzeug nicht gefunden' }
    end

    local row = rows[1]
    if tonumber(row.stored) ~= 1 then
        return { ok = false, message = 'Fahrzeug ist nicht eingeparkt' }
    end

    if normalizeParking(row.parking) ~= garageKey then
        return { ok = false, message = 'Fahrzeug gehört nicht zu dieser Garage' }
    end

    local props = decodeVehicleProps(row.vehicle)
    local updateQuery = ([[
        UPDATE `%s` SET %s = 0 WHERE owner = ? AND REPLACE(plate, ' ', '') = REPLACE(?, ' ', '')
    ]]):format(tableName, storedCol)

    ECGarage.MySQL.Await(updateQuery, { identifier, plateKey })

    return {
        ok = true,
        plate = row.plate,
        props = props,
        slot = slot,
        garageId = tostring(garageId),
        slotIndex = slotIndex,
    }
end

function ECGarage.Server.SaveVehicleMeta(source, data)
    if not ECGarage.MySQL.IsReady() then
        return { ok = false, message = 'Kein MySQL aktiv' }
    end

    if not data or not data.plate then
        return { ok = false, message = 'Kennzeichen fehlt' }
    end

    local identifier = ECGarage.Bridge.GetIdentifier(source)
    if not identifier then
        return { ok = false, message = 'Spieler nicht gefunden' }
    end

    if ECGarage.Bridge.Framework ~= 'esx' then
        return { ok = false, message = 'Speichern aktuell nur für ESX' }
    end

    local tableName = Config.VehicleTables.esx or 'owned_vehicles'
    local plateKey = tostring(data.plate):gsub('^%s+', ''):gsub('%s+$', '')

    local ownerRow = ECGarage.MySQL.Await(([[
        SELECT plate FROM `%s` WHERE owner = ? AND REPLACE(plate, ' ', '') = REPLACE(?, ' ', '') LIMIT 1
    ]]):format(tableName), { identifier, plateKey })

    if not ownerRow or not ownerRow[1] then
        return { ok = false, message = 'Fahrzeug gehört dir nicht' }
    end

    local plateDb = ownerRow[1].plate
    local customName = data.customName
    if customName == '' or customName == nil then
        customName = nil
    else
        customName = tostring(customName):sub(1, 64)
    end

    local note = data.note and tostring(data.note):sub(1, 200) or ''
    local favorite = data.favorite and 1 or 0

    ECGarage.MySQL.Await([[
        INSERT INTO `ec_garage_vehicle_meta` (`plate`, `custom_name`, `note`, `favorite`)
        VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            `custom_name` = VALUES(`custom_name`),
            `note` = VALUES(`note`),
            `favorite` = VALUES(`favorite`),
            `updated_at` = CURRENT_TIMESTAMP
    ]], { plateDb, customName, note, favorite })

    return {
        ok = true,
        plate = plateDb,
        customName = customName,
        note = note,
        favorite = favorite == 1,
    }
end

RegisterNetEvent('ec_garage:saveVehicleMeta', function(data)
    local src = source
    local result = ECGarage.Server.SaveVehicleMeta(src, data)
    TriggerClientEvent('ec_garage:saveVehicleMetaResult', src, result)
end)

RegisterNetEvent('ec_garage:takeOutVehicle', function(garageId, plate, slotIndex)
    local src = source
    slotIndex = tonumber(slotIndex)
    if not slotIndex then
        TriggerClientEvent('ec_garage:takeOutResult', src, { ok = false, message = 'Slot fehlt' })
        return
    end

    local result = ECGarage.Server.TakeOutVehicle(src, garageId, plate, slotIndex)
    TriggerClientEvent('ec_garage:takeOutResult', src, result)
end)
