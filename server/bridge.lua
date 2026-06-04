ECGarage.Bridge = ECGarage.Bridge or {}

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

ECGarage.Bridge.Framework = detectFramework()

function ECGarage.Bridge.GetIdentifier(source)
    local fw = ECGarage.Bridge.Framework

    if fw == 'esx' then
        local ok, ESX = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok and ESX then
            local xPlayer = ESX.GetPlayerFromId(source)
            if xPlayer then
                return xPlayer.identifier
            end
        end
    elseif fw == 'qbox' then
        local player = exports.qbx_core:GetPlayer(source)
        if player and player.PlayerData then
            return player.PlayerData.citizenid
        end
    elseif fw == 'qbcore' then
        local ok, QBCore = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        if ok and QBCore then
            local player = QBCore.Functions.GetPlayer(source)
            if player and player.PlayerData then
                return player.PlayerData.citizenid
            end
        end
    end

    return nil
end

local function normalizeGroupName(name)
    if name == nil then
        return nil
    end
    return string.lower(tostring(name):gsub('^%s+', ''):gsub('%s+$', ''))
end

function ECGarage.Bridge.GetPlayerGroup(source)
    local fw = ECGarage.Bridge.Framework

    if fw == 'esx' then
        local ok, ESX = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok and ESX then
            local xPlayer = ESX.GetPlayerFromId(source)
            if xPlayer then
                if xPlayer.getGroup then
                    return xPlayer.getGroup()
                end
                return xPlayer.group
            end
        end
    elseif fw == 'qbox' then
        local player = exports.qbx_core:GetPlayer(source)
        if player and player.PlayerData then
            return player.PlayerData.group or player.PlayerData.permission
        end
    elseif fw == 'qbcore' then
        local ok, QBCore = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        if ok and QBCore then
            local player = QBCore.Functions.GetPlayer(source)
            if player and player.PlayerData then
                return player.PlayerData.group or player.PlayerData.permission
            end
        end
    end

    return nil
end

function ECGarage.Bridge.HasCreatorGroup(source)
    local allowed = Config.CreatorGroups
    if not allowed or #allowed == 0 then
        return false
    end

    local playerGroup = normalizeGroupName(ECGarage.Bridge.GetPlayerGroup(source))
    if playerGroup then
        for _, group in ipairs(allowed) do
            if normalizeGroupName(group) == playerGroup then
                return true
            end
        end
    end

    local fw = ECGarage.Bridge.Framework
    if fw == 'qbcore' or fw == 'qbox' then
        local ok, QBCore = pcall(function()
            if fw == 'qbox' then
                return exports.qbx_core
            end
            return exports['qb-core']:GetCoreObject()
        end)
        if ok and QBCore and QBCore.Functions and QBCore.Functions.HasPermission then
            for _, group in ipairs(allowed) do
                if QBCore.Functions.HasPermission(source, group) then
                    return true
                end
            end
        end
    end

    return false
end

RegisterNetEvent('ec_garage:requestCanManage', function()
    local src = source
    TriggerClientEvent('ec_garage:syncCanManage', src, ECGarage.Bridge.CanUseCreator(src))
end)

function ECGarage.Bridge.CanUseCreator(source)
    local ace = Config.CreatorAce
    if ace and ace ~= '' and IsPlayerAceAllowed(source, ace) then
        return true
    end

    if ECGarage.Bridge.HasCreatorGroup(source) then
        return true
    end

    local hasAce = ace and ace ~= ''
    local hasGroups = Config.CreatorGroups and #Config.CreatorGroups > 0
    if not hasAce and not hasGroups then
        return true
    end

    return false
end
