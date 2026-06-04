ECGarage = ECGarage or {}
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
    nuiScreen = 'creator'
    ECGarage.UI.SetFocus(true)
    SendNUIMessage({
        action = 'openCreator',
        garages = ECGarage.GetGaragesForNui(),
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
