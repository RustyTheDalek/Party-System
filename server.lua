AddEventHandler("playerJoining", function()
    local source = source

    print(source .. " is joining")
end)

local playerList = {}

function GetPlayerList()
    playerList = {}

    print("Getting players")

    for _, playerSource in ipairs(GetPlayers()) do
        
        local name = GetPlayerName(playerSource)
        print("Source: " .. playerSource .. " in-game with name " .. name)

        table.insert(playerList, {
            source = playerSource,
            name = name
        })

    end
end

AddEventHandler('onResourceStart', function (resourceName) 
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    GetPlayerList()
end)

RegisterNetEvent('partySystem:getPlayers')
AddEventHandler('partySystem:getPlayers', function()
    local source = source
    TriggerClientEvent('partySystem:recievePlayers', source, playerList)
end)
