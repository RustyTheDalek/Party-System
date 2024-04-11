local playerList = {}
local inParty = false
local currentPartySource = -1
local mutedInvites = false --When set invites will be ignored 
local mutedReason = ""

function updatePlayerList(players)
    SendNUIMessage({
        action = "sendPlayers",
        players = players,
        ownSource = GetPlayerServerId(PlayerId())
    })
end

TriggerServerEventResource('getPlayers')

function OnResourceStart()
    if( playerList ~= nil and getTableSize(playerList) > 0) then
        print("Have players, loading...")
        print(dump(playerList))
        updatePlayerList(playerList)
    else
        print("no players, requesting...")
        TriggerServerEventResource('getPlayers')
    end
end

AddEventHandler('onClientResourceStart',function(resourceName)
    if(GetCurrentResourceName() ~= resourceName) then return end
end)

--#region Network Events ------

RegisterNetEvent(GetCurrentResourceName() .. ':recievePlayers')
AddEventHandler(GetCurrentResourceName() .. ':recievePlayers', function(newPlayerList)
    print("received Playerlist")
    print(dump(newPlayerList))
    playerList = newPlayerList
    updatePlayerList(newPlayerList)
end)

RegisterNetEvent(GetCurrentResourceName() .. ':playerJoining')
AddEventHandler(GetCurrentResourceName() .. ':playerJoining', function(source, name)
    SendNUIMessage({
        action = "playerJoining",
        source = source,
        name = name
    })
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

RegisterNetEvent(GetCurrentResourceName() .. ':joinedParty')
AddEventHandler(GetCurrentResourceName() .. ':joinedParty', function(partyOwnerSource, currentMembers)
    print("Joined party")
    inParty = true
    currentPartySource = partyOwnerSource

    SendNUIMessage({
        action = "currentMembers",
        ownSource = GetPlayerServerId(PlayerId()),
        currentMembers = currentMembers
    })
end)


RegisterNetEvent(GetCurrentResourceName() .. ':onRemoveFromParty')
AddEventHandler(GetCurrentResourceName() .. ':onRemoveFromParty', function(reason)
    inParty = false
    currentPartySource = -1
    SendNUIMessage({
        action = "onRemoveFromParty",
        reason = reason
    })
end)

RegisterNetEvent(GetCurrentResourceName() .. ':removeFromParty')
AddEventHandler(GetCurrentResourceName() .. ':removeFromParty', function(sourceToRemove)
    SendNUIMessage({
        action = "removeFromParty",
        source = sourceToRemove
    })
end)

RegisterNetEvent(GetCurrentResourceName() .. ':removeInvite')
AddEventHandler(GetCurrentResourceName() .. ':removeInvite', function(sourceToRemove)
    SendNUIMessage({
        action = "removeInvite",
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

RegisterNUICallback('leaveParty', function()
    print("Leaving Party")

    if(inParty) then
        TriggerServerEventResource('leaveParty', currentPartySource)
    else
        print("No party to leave")
    end
end)
--#endregion