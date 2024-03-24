
local inParty = false
local mutedInvites = false --When set invites will be ignored 
local mutedReason = ""

function updatePlayerList(players)
    SendNUIMessage({
        action = "sendPlayers",
        players = players,
        ownSource = GetPlayerServerId(PlayerId())
    })
end

--#region Network Events ------
AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    TriggerServerEventResource('getPlayers')
end)

RegisterNetEvent(GetCurrentResourceName() .. ':recievePlayers')
AddEventHandler(GetCurrentResourceName() .. ':recievePlayers', function(playerList)
    updatePlayerList(playerList)
end)

RegisterNetEvent(GetCurrentResourceName() .. ':playerDropped')
AddEventHandler(GetCurrentResourceName() .. ':playerDropped', function(source)
    SendNUIMessage({
        action = "playerDropped",
        source = source
    })
end)

RegisterNetEvent(GetCurrentResourceName() .. ':playerJoinedParty')
AddEventHandler(GetCurrentResourceName() .. ':playerJoinedParty', function(sourceJoining, name, hostName)
    SendNUIMessage({
        action = "playerJoinedParty",
        ownSource = GetPlayerServerId(PlayerId()),
        source = sourceJoining,
        name = name,
        hostName = hostName
    })
end)

RegisterNetEvent(GetCurrentResourceName() .. ':closeParty')
AddEventHandler(GetCurrentResourceName() .. ':closeParty', function()
    SendNUIMessage({
        action = "closeParty"
    })
end)

RegisterNetEvent(GetCurrentResourceName() .. ':onRemoveFromParty')
AddEventHandler(GetCurrentResourceName() .. ':onRemoveFromParty', function()
    SendNUIMessage({
        action = "onRemoveFromParty"
    })
end)

RegisterNetEvent(GetCurrentResourceName() .. ':removeFromParty')
AddEventHandler(GetCurrentResourceName() .. ':removeFromParty', function(sourceToRemove)
    SendNUIMessage({
        action = "removeFromParty",
        source = sourceToRemove
    })
end)

--#endregion

--#region NUI Callbacks -----

RegisterNUICallback('invitePlayer', function(data)
    if(data.inviteSource == nil) then
        print("Invite source nil, cannot invite")
        return
    end

    TriggerServerEventResource('invitePlayer', data.inviteSource)
end)

RegisterNUICallback('acceptInvite', function(data)
    TriggerServerEventResource('acceptInvite', data.acceptSource)
end)

RegisterNUICallback('rejectInvite', function(data)
    print("Rejecting Invite")
    TriggerServerEventResource('rejectInvite' , data.rejectSource)
end)

RegisterNUICallback('removePlayer', function(data)
    print("Remove Invite")
    TriggerServerEventResource('removePlayer', data.sourceToRemove)
end)
--#endregion