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

    -- SetNuiFocusKeepInput(socialActive)
    SetNuiFocus(socialActive, socialActive)

end

function update()

    if IsControlJustReleased(1, 172) then
        -- run code here
        toggleSocial()
    end
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

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) 

        update()
    end
end)