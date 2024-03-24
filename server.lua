local playerList = {}
local parties = {}

AddEventHandler("playerJoining", function()
    local source = source

    print(source .. " is joining")

    TriggerClientEventResource('recievePlayers', source, playerList)

    local name = GetPlayerName(source)
    playerList[source] = {
        source = source,
        name = name
    }
end)

AddEventHandler("playerDropped", function()
    local source = source

    playerList[source] = nil

    for index, party in pairs(parties) do
        if(index == source) then
            party:Close()
        else
            party:removePlayer(source)
        end
    end

end)

AddEventHandler("onServerResourceStart", function(resourceName)
    if ( GetCurrentResourceName() ~= resourceName ) then
        return
    end

    GetPlayerList()
end)

function GetPlayerList()
    playerList = {}

    for _, playerSource in ipairs(GetPlayers()) do
        local name = GetPlayerName(playerSource)
        print("Source: " .. playerSource .. " in-game with name " .. name)

        playerList[playerSource] = {
            source = playerSource,
            name = name
        }

    end

    TriggerClientEventResource('recievePlayers', -1, playerList)

end

function inviteValidate(source, inviteSource)

    if (source == nil or inviteSource == nil) then
        print("no sources to assess")
        return false
    end

    -- if(source == inviteSource) then
    --     print("Can't accept/reject self!")
    --     return
    -- end

    local party = parties[inviteSource]

    if (party == nil) then
        print("Party doesn't exist")
        return false
    end

    if (party.members[source] ~= nil) then
        print("Already in party, can't accept/reject")
        return false
    end

    if (party.invited[source] == nil) then
        print("Can't accept/reject no invite")
        return false
    end

    return true
end

-- #region Network Events -----
RegisterNetEvent(GetCurrentResourceName() .. ':getPlayers')
AddEventHandler(GetCurrentResourceName() .. ':getPlayers', function()
    local source = source
    TriggerClientEventResource('recievePlayers', source, playerList)
end)

RegisterNetEvent(GetCurrentResourceName() .. ':invitePlayer')
AddEventHandler(GetCurrentResourceName() .. ':invitePlayer', function(sourceToInvite)
    local source = source

    -- if(source == inviteSource) then
    --     print("Can't invite self!")
    --     return
    -- end

    local party = parties[source]

    if (party == nil) then
        party = Party:New(source)
    else 
        if party.members[sourceToInvite] ~= nil then
            print("already in party, can't invite")
            return
        end

        if party.invited[sourceToInvite] ~= nil then
            print("already invited, can't invite")
            return
        end
    end

    party:InvitePlayer(sourceToInvite, source, GetPlayerName(source))
    parties[source] = party

end)

RegisterNetEvent(GetCurrentResourceName() .. ':rejectInvite')
AddEventHandler(GetCurrentResourceName() .. ':rejectInvite', function(sourceToReject)
    local source = source

    if (not inviteValidate(source, sourceToReject)) then
        return
    end

    parties[sourceToReject]:RejectInvite(source, sourceToReject)

end)

RegisterNetEvent(GetCurrentResourceName() .. ':acceptInvite')
AddEventHandler(GetCurrentResourceName() .. ':acceptInvite', function(sourceToAccept)
    local source = source

    if (not inviteValidate(source, sourceToAccept)) then
        return
    end

    parties[sourceToAccept]:AcceptInvite(source, sourceToAccept)

end)

RegisterNetEvent(GetCurrentResourceName() .. ':removePlayer')
AddEventHandler(GetCurrentResourceName() .. ':removePlayer', function(sourceToRemove)
    local source = source

    local party = parties[source]

    if (party == nil) then
        print("No party to remove from")
        return
    end

    if (party.members[sourceToRemove] == nil) then
        print("No member with that source")
        return
    end

    party:RemovePlayer(sourceToRemove)

end)

-- #endregion

function Update()
    for index, party in pairs(parties) do
        party:Update()
        if (party.empty) then
            print("party empty, removing")
            party:Close()
            parties[index] = nil
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        Update()
    end
end)
