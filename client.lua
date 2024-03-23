local socialActive = false;
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
    TriggerServerEvent('partySystem:getPlayers')
end)

RegisterNetEvent('partySystem:recievePlayers')
AddEventHandler('partySystem:recievePlayers', function(playerList)
    playerList = playerList

    print(dump(playerList))

    updatePlayerList(playerList)

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
    end
end)