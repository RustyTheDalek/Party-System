RegisterNetEvent(GetCurrentResourceName() .. ':onRecieveInvite')
AddEventHandler(GetCurrentResourceName() .. ':onRecieveInvite', function(invitingSource, invitingName)

    print('Recieving Invite from ' .. invitingName)

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
AddEventHandler(GetCurrentResourceName() .. ':inviteRejected', function(inviteRejectedSource, inviteRejectName)
    SendNUIMessage({
        action = "inviteRejected",
        source = inviteRejectedSource,
        name = inviteRejectName
    })
end)

RegisterNetEvent(GetCurrentResourceName() .. ':inviteTimedOut')
AddEventHandler(GetCurrentResourceName() .. ':inviteTimedOut', function(inviteTimedOutSource, inviteTimeoutName)
    SendNUIMessage({
        action = "inviteTimedOut",
        source = inviteTimedOutSource,
        name = inviteTimeoutName
    })
end)

RegisterNetEvent(GetCurrentResourceName() .. ':playerAcceptedInvite')
AddEventHandler(GetCurrentResourceName() .. ':playerAcceptedInvite', function(sourceJoining, name)
    SendNUIMessage({
        action = "playerAcceptedInvite",
        source = sourceJoining,
        name = name
    })
end)

RegisterNetEvent(GetCurrentResourceName() .. ':hostRemovedPlayer')
AddEventHandler(GetCurrentResourceName() .. ':hostRemovedPlayer', function(source)
    print("Host is removing player")
    SendNUIMessage({
        action = "hostRemovedPlayer",
        source = source
    })
end)

