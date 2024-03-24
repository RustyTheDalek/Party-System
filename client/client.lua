local socialActive = false
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

function toggleSocial()
    socialActive = not socialActive

    print(socialActive)

    SendNUIMessage({
        action = "toggleSocial",
        active = socialActive
    })

    SetNuiFocus(socialActive, socialActive)
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
    playerList = playerList

    print(dump(playerList))

    updatePlayerList(playerList)
end)

RegisterNetEvent(GetCurrentResourceName() .. ':invitePlayer')
AddEventHandler(GetCurrentResourceName() .. ':invitePlayer', function(invitingSource, invitingName)

    print('Recieveing Invite from ' .. invitingName)

    SendNUIMessage({
        action = "recieveInvite",
        source = invitingSource,
        name = invitingName
    })

end)

RegisterNetEvent(GetCurrentResourceName() .. ':onPartyStart')
AddEventHandler(GetCurrentResourceName() .. ':onPartyStart', function()
    SendNUIMessage({
        action = "onPartyStart"
    })
end)

RegisterNetEvent(GetCurrentResourceName() .. ':inviteRejected')
AddEventHandler(GetCurrentResourceName() .. ':inviteRejected', function(inviteRejectedSource)
    SendNUIMessage({
        action = "inviteRejected",
        source = inviteRejectedSource
    })
end)

RegisterNetEvent(GetCurrentResourceName() .. ':inviteTimedOut')
AddEventHandler(GetCurrentResourceName() .. ':inviteTimedOut', function(inviteTimedOutSource)
    SendNUIMessage({
        action = "inviteTimedOut",
        source = inviteTimedOutSource
    })
end)

RegisterNetEvent(GetCurrentResourceName() .. ':playerJoinedParty')
AddEventHandler(GetCurrentResourceName() .. ':playerJoinedParty', function(sourceJoining, name, owner)
    SendNUIMessage({
        action = "playerJoinedParty",
        ownSource = GetPlayerServerId(PlayerId()),
        source = sourceJoining,
        name = name,
        owner = owner
    })
end)

RegisterNetEvent(GetCurrentResourceName() .. ':closeParty')
AddEventHandler(GetCurrentResourceName() .. ':closeParty', function()
    SendNUIMessage({
        action = "closeParty"
    })
end)

--#endregion

--#region Input -----

RegisterKeyMapping('socialToggle', 'Toggle Social menu', 'keyboard', 'o')

RegisterCommand('socialToggle', function()
    print("button pressed")
    toggleSocial()
end, false)

RegisterNUICallback('closeSocial', function()
    print("closing social");
    socialActive = false
    SetNuiFocus(socialActive, socialActive)
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

--#endregion