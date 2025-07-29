ESX = exports['es_extended']:getSharedObject()

local noclip = false
local isPanelOpen = false

CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustReleased(0, Config.OpenKey) and not isPanelOpen then
            local playerGroup = ESX.GetPlayerData().group
            if Config.AdminGroups[playerGroup] then
                isPanelOpen = true
                TriggerServerEvent('admin_panel:getPlayers')
                TriggerServerEvent('admin_panel:getFullLog')
                SetNuiFocus(true, true)
                SendNUIMessage({ type = 'show' })
            else
                ESX.ShowNotification("Nincs jogosultságod a panel megnyitásához.")
            end
        end
    end
end)

RegisterNUICallback('closePanel', function(_, cb)
    isPanelOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'hide' })
    cb('ok')
end)

RegisterNUICallback('performAction', function(data, cb) 
    TriggerServerEvent('admin_panel:performAction', data.action, data.target)
    cb('ok') 
end)

RegisterNUICallback('performSelfAction', function(data, cb)
    if data.action == 'noclip' then
        noclip = not noclip
        SetEntityVisible(PlayerPedId(), not noclip, false)
        SetEntityCollision(PlayerPedId(), not noclip, false)
        SetEntityInvincible(PlayerPedId(), noclip)
    elseif data.action == 'godmode' then
        local godmode = not GetPlayerInvincible(PlayerPedId())
        SetPlayerInvincible(PlayerPedId(), godmode)
        ESX.ShowNotification(godmode and "God mode bekapcsolva." or "God mode kikapcsolva.")
    end
    cb('ok')
end)

RegisterNetEvent('admin_panel:receivePlayers', function(players) SendNUIMessage({ type = 'updatePlayerList', players = players }) end)
RegisterNetEvent('admin_panel:receiveFullLog', function(log) SendNUIMessage({ type = 'updateLog', log = log }) end)
RegisterNetEvent('admin_panel:newLogEntry', function(entry) if isPanelOpen then SendNUIMessage({ type = 'appendLog', entry = entry }) end end)

CreateThread(function()
    while true do
        Wait(0)
        if noclip then
            local ped = PlayerPedId()
            local camRot = GetGameplayCamRot(2)
            SetEntityRotation(ped, 0.0, 0.0, camRot.z, 2, true)
            SetEntityVelocity(ped, 0.0, 0.0, 0.0)
            local speed = 1.0
            if IsControlPressed(0, 21) then speed = 5.0 end 
            if IsControlPressed(0, 32) then SetEntityCoords(ped, GetOffsetFromEntityInWorldCoords(ped, 0.0, speed, 0.0), false, false, false, true) end -- W
            if IsControlPressed(0, 33) then SetEntityCoords(ped, GetOffsetFromEntityInWorldCoords(ped, 0.0, -speed, 0.0), false, false, false, true) end -- S
        end
    end
end)