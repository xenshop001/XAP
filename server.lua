ESX = exports['es_extended']:getSharedObject()

local LogHistory = {} 
local maxLogEntries = 100 

function AddToLog(logType, message)
    local entry = {type = logType, msg = message, time = os.date('%H:%M:%S')}
    table.insert(LogHistory, 1, entry)

    if #LogHistory > maxLogEntries then
        table.remove(LogHistory)
    end
    
    TriggerClientEvent('admin_panel:newLogEntry', -1, entry)
end

ESX.RegisterServerCallback('admin_panel:isAdmin', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer and Config.AdminGroups[xPlayer.getGroup()])
end)

RegisterNetEvent('admin_panel:getPlayers')
AddEventHandler('admin_panel:getPlayers', function()
    local players = {}
    for _, playerId in ipairs(ESX.GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            table.insert(players, { id = xPlayer.source, name = xPlayer.getName() })
        end
    end
    TriggerClientEvent('admin_panel:receivePlayers', source, players)
end)

RegisterNetEvent('admin_panel:performAction')
AddEventHandler('admin_panel:performAction', function(action, targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not (xPlayer and Config.AdminGroups[xPlayer.getGroup()]) then return end

    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then return end

    local adminName = xPlayer.getName()
    local targetName = xTarget.getName()

    if action == 'kick' then
        AddToLog('kick', ("%s kirúgta %s játékost."):format(adminName, targetName))
        xTarget.kick(("%s kirúgott a szerverről."):format(adminName))
    elseif action == 'ban' then
        AddToLog('ban', ("%s kitiltotta %s játékost."):format(adminName, targetName))
        ESX.BanPlayer(xTarget, ("%s kitiltott a szerverről."):format(adminName))
    elseif action == 'goto' then
        xPlayer.setCoords(xTarget.getCoords())
    elseif action == 'bring' then
        xTarget.setCoords(xPlayer.getCoords())
    end
end)

AddEventHandler('esx:playerLoaded', function(source, xPlayer, isNew)
    AddToLog('connect', ("%s csatlakozott a szerverhez."):format(xPlayer.getName()))
end)

AddEventHandler('playerDropped', function(reason)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        AddToLog('disconnect', ("%s kilépett. (%s)"):format(xPlayer.getName(), reason))
    end
end)

RegisterNetEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
    local deadPlayer = ESX.GetPlayerFromId(data.victim)
    if deadPlayer then
        AddToLog('death', ("%s meghalt."):format(deadPlayer.getName()))
    end
end)


RegisterNetEvent('admin_panel:getFullLog')
AddEventHandler('admin_panel:getFullLog', function()
    TriggerClientEvent('admin_panel:receiveFullLog', source, LogHistory)
end)