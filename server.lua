local playerList = {}
local parties = {}

--#region Exports -----
--Whether source is currently hosting a party
function HostingParty(source)
    return parties[source] ~= nil
end

function GetPartySources(source)
    if(HostingParty()) then
        return parties[source]:GetPartySources()
    end
end
--#endregion


function TriggerClientEventResourceForPlayers(event, ...)
    for _, player in pairs(playerList) do
        TriggerClientEventResource(event, player.source, ...)
    end
end

AddEventHandler("playerJoining", function()
    local source = source
    local name = GetPlayerName(source)
    print(source .. " is joining")

    TriggerClientEventResource('recievePlayers', source, playerList)
    TriggerClientEventResourceForPlayers('playerJoining', source, name)

    playerList[source] = {
        source = source,
        name = name
    }
end)

AddEventHandler("playerDropped", function()
    local source = source

    playerList[source] = nil
    TriggerClientEventResource('playerDropped', -1, source)

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

    print("Inviting " .. sourceToInvite)

    if(source == sourceToInvite) then
        print("Can't invite self!")
        return
    end

    local party = parties[source]

    if (party == nil) then
        print("Creating new party")
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
        print("No member with source " .. sourceToRemove)
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
