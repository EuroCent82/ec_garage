--- Admin/Manager: Garage bearbeiten & löschen (Target)

ECGarage.Client = ECGarage.Client or {}

ECGarage.PendingCreatorGarageId = nil

local function notify(msg, ntype)
    if GetResourceState('ox_lib') == 'started' then
        pcall(function()
            exports.ox_lib:notify({
                title = 'EC Garage',
                description = msg,
                type = ntype or 'inform',
            })
        end)
        return
    end
    TriggerEvent('chat:addMessage', {
        color = { 200, 220, 255 },
        args = { 'Garage', msg },
    })
end

function ECGarage.Client.EditGarage(garage)
    if not garage or not ECGarage.Client.CanManageGarages() then
        notify('Keine Berechtigung', 'error')
        return
    end

    ECGarage.PendingCreatorGarageId = tostring(garage.id)
    if ECGarage.UI.IsOpen() then
        ECGarage.UI.Close()
        Wait(300)
    end
    TriggerServerEvent('ec_garage:requestGarageList')
end

local function confirmDeleteGarage(garage)
    if GetResourceState('ox_lib') == 'started' then
        local result = exports.ox_lib:alertDialog({
            header = 'Garage löschen',
            content = ('Garage **%s** wirklich löschen?\n\nDas kann nicht rückgängig gemacht werden.'):format(garage.name or garage.id),
            centered = true,
            cancel = true,
            labels = { confirm = 'Löschen', cancel = 'Abbrechen' },
        })
        if result == 'confirm' then
            TriggerServerEvent('ec_garage:deleteGarage', garage.id)
        end
        return
    end

    TriggerServerEvent('ec_garage:deleteGarage', garage.id)
    notify(('Garage „%s“ wird gelöscht…'):format(garage.name or garage.id), 'warning')
end

function ECGarage.Client.DeleteGarage(garage)
    if not garage or not ECGarage.Client.CanManageGarages() then
        notify('Keine Berechtigung', 'error')
        return
    end

    for _, protected in ipairs(Config.ProtectedGarageIds or {}) do
        if tostring(protected) == tostring(garage.id) then
            notify('Diese Garage ist geschützt und kann nicht gelöscht werden', 'error')
            return
        end
    end

    confirmDeleteGarage(garage)
end

RegisterNetEvent('ec_garage:openCreator', function(garages)
    if ECGarage.UI.IsOpen() then
        return
    end
    if garages then
        ECGarage.SyncGarageSeedFromNui(garages)
        ECGarage.OnGaragesSynced()
    end

    local editId = ECGarage.PendingCreatorGarageId
    ECGarage.PendingCreatorGarageId = nil

    ECGarage.UI.OpenCreatorWithData(garages or ECGarage.GetGaragesForNui(), editId)
end)

RegisterNetEvent('ec_garage:deleteGarageResult', function(ok, message)
    if ok then
        notify(message or 'Garage gelöscht', 'success')
    else
        notify(message or 'Löschen fehlgeschlagen', 'error')
    end
end)
