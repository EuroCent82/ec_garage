ECGarage.UI = ECGarage.UI or {}

local nuiOpen = false
local nuiScreen = nil

function ECGarage.UI.IsOpen()
    return nuiOpen
end

function ECGarage.UI.SetFocus(state)
    SetNuiFocus(state, state)
    SetNuiFocusKeepInput(false)
    nuiOpen = state
    if not state then
        nuiScreen = nil
    end
end

function ECGarage.UI.EnsureFocus()
    if nuiOpen then
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(false)
    end
end

function ECGarage.UI.OpenGarage(opts)
    opts = opts or {}
    if nuiOpen then
        return
    end
    nuiScreen = 'garage'
    ECGarage.UI.SetFocus(true)
    SendNUIMessage({
        action = 'openGarage',
        mode = opts.mode or 'land',
        garageName = opts.garageName,
        garageId = opts.garageId,
        vehicles = opts.vehicles,
    })
end

function ECGarage.UI.OpenCreator()
    if nuiOpen then
        return
    end
    TriggerServerEvent('ec_garage:requestGarageList')
end

function ECGarage.UI.OpenCreatorWithData(garages, editGarageId)
    if nuiOpen then
        return
    end
    nuiScreen = 'creator'
    ECGarage.UI.SetFocus(true)
    SendNUIMessage({
        action = 'openCreator',
        garages = garages or ECGarage.GetGaragesForNui(),
        editGarageId = editGarageId,
    })
end

function ECGarage.UI.Close()
    if not nuiOpen then
        return
    end
    if nuiScreen == 'creator' then
        SendNUIMessage({ action = 'closeCreator' })
    else
        SendNUIMessage({ action = 'close' })
    end
    ECGarage.UI.SetFocus(false)
end

RegisterNUICallback('close', function(_, cb)
    ECGarage.UI.Close()
    cb('ok')
end)

RegisterNUICallback('nuiFocus', function(data, cb)
    if nuiOpen and data and data.active ~= false then
        ECGarage.UI.EnsureFocus()
    end
    cb('ok')
end)

RegisterNUICallback('saveVehicleMeta', function(data, cb)
    TriggerServerEvent('ec_garage:saveVehicleMeta', data)
    cb({ ok = true, pending = true })
end)

RegisterNetEvent('ec_garage:saveVehicleMetaResult', function(result)
    SendNUIMessage({
        action = 'saveVehicleMetaResult',
        ok = result and result.ok == true,
        message = result and result.message,
        plate = result and result.plate,
        customName = result and result.customName,
        note = result and result.note,
        favorite = result and result.favorite,
    })
end)
