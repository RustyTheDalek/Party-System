RegisterNetEvent(GetCurrentResourceName() .. ':invitePlayer')
AddEventHandler(GetCurrentResourceName() .. ':invitePlayer', function(invitingSource, invitingName)

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
