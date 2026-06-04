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
