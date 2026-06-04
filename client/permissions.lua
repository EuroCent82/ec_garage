--- Client: gleiche Creator-Rechte wie Server (admin, manager, ACE)

ECGarage.Client = ECGarage.Client or {}

local function detectFramework()
    if Config.Framework ~= 'auto' then
        return Config.Framework
    end
    if GetResourceState('es_extended') == 'started' then
        return 'esx'
    end
    if GetResourceState('qbx_core') == 'started' then
        return 'qbox'
    end
    if GetResourceState('qb-core') == 'started' then
        return 'qbcore'
    end
    return 'standalone'
end

local clientFramework = detectFramework()

local function normalizeGroupName(name)
    if name == nil then
        return nil
    end
    return string.lower(tostring(name):gsub('^%s+', ''):gsub('%s+$', ''))
end

function ECGarage.Client.GetLocalGroup()
    if clientFramework == 'esx' then
        local ok, ESX = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok and ESX then
            local data = ESX.GetPlayerData()
            if data and data.group then
                return data.group
            end
        end
    elseif clientFramework == 'qbcore' then
        local ok, QBCore = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        if ok and QBCore then
            local data = QBCore.Functions.GetPlayerData()
            if data and data.group then
                return data.group
            end
        end
    elseif clientFramework == 'qbox' then
        local data = exports.qbx_core:GetPlayerData()
        if data then
            return data.group or data.permission
        end
    end
    return nil
end

local canManageCached = nil

local function hasCreatorGroup()
    local playerGroup = normalizeGroupName(ECGarage.Client.GetLocalGroup())
    if not playerGroup then
        return false
    end
    for _, group in ipairs(Config.CreatorGroups or {}) do
        if normalizeGroupName(group) == playerGroup then
            return true
        end
    end
    return false
end

--- IsPlayerAceAllowed existiert nur auf dem Server — Client nutzt Gruppe + Server-Cache.
function ECGarage.Client.CanManageGarages()
    if canManageCached ~= nil then
        return canManageCached
    end
    return hasCreatorGroup()
end

function ECGarage.Client.RefreshCanManage()
    TriggerServerEvent('ec_garage:requestCanManage')
end

RegisterNetEvent('ec_garage:syncCanManage', function(canManage)
    local prev = canManageCached
    canManageCached = canManage == true
    if prev ~= canManageCached and ECGarage.RefreshWorld then
        ECGarage.RefreshWorld()
    end
end)

CreateThread(function()
    Wait(2500)
    ECGarage.Client.RefreshCanManage()
end)

RegisterNetEvent('esx:playerLoaded', function()
    canManageCached = nil
    SetTimeout(500, function()
        ECGarage.Client.RefreshCanManage()
    end)
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    canManageCached = nil
    SetTimeout(500, function()
        ECGarage.Client.RefreshCanManage()
    end)
end)

