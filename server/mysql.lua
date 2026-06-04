ECGarage.MySQL = ECGarage.MySQL or {}

local function flavour()
    if GetResourceState('oxmysql') == 'started' then
        return 'oxmysql'
    end
    if GetResourceState('mysql-async') == 'started' then
        return 'mysql-async'
    end
    return nil
end

function ECGarage.MySQL.IsReady()
    return flavour() ~= nil
end

function ECGarage.MySQL.Query(query, params, cb)
    params = params or {}
    local f = flavour()

    if f == 'mysql-async' then
        if MySQL and MySQL.Async and MySQL.Async.fetchAll then
            MySQL.Async.fetchAll(query, params, cb or function() end)
        elseif cb then
            cb(nil)
        end
        return
    end

    if f == 'oxmysql' then
        exports.oxmysql:query(query, params, cb or function() end)
        return
    end

    if cb then
        cb(nil)
    end
end

function ECGarage.MySQL.Await(query, params)
    local p = promise.new()
    ECGarage.MySQL.Query(query, params, function(result)
        p:resolve(result or {})
    end)
    return Citizen.Await(p)
end
