Party = {
    owner = nil, 
    members = {},
    invited = {},
    empty = false
}

function Party:New(owner)
    local o = o or {}
    self.owner = owner
    TriggerClientEventResource('onPartyStart', source)
    setmetatable(o, self)
    self.__index = self
    return o
end

function Party:Update()
    for index,invite in pairs(self.invited) do
        if(GetGameTimer() - invite.timeInvited > Config.data.inviteTimeoutSeconds * 1000) then
            print("Invited timed out for source " .. index)
            TriggerClientEventResource('inviteTimedOut', self.owner, index)
            table.remove(self.invited, index)
        end
    end

    self.empty = (self.members == nil and self.invited == nil) or (#self.members == 0 and #self.invited == 0)

end

function Party:Close()
    TriggerClientEventResource('closeParty', self.owner)
end

function Party:InvitePlayer(source, invitingSource, invitingName)
    if(self.invited[source] == nil) then
        print("Can invite " .. invitingName)

        TriggerClientEventResource('invitePlayer', source, invitingSource, invitingName)

        self.invited[source] = { timeInvited = GetGameTimer() }
    else 
        print("Already invited")
    end
end

function Party:PlayerInParty(source)
    if(self.members[source] ~= nil) then
        print("player in party already")
        return true
    end

    return false
end

function Party:RejectInvite(source, sourceRejected)
    table.remove(self.invited, source)
    TriggerClientEventResource('inviteRejected', sourceRejected, source)
end

function Party:AcceptInvite(source, sourceAccepted)

    table.remove(self.invited, source)
    table.insert(self.members, source)

    local name = GetPlayerName(sourceAccepted)

    TriggerClientEventResource('playerJoinedParty', self.owner, sourceAccepted, name, true)
end

function Party:RemovePlayer(source)
    table.remove(self.members, source)
    TriggerClientEventResource('onRemoveFromParty', source)

    for memberSource, member in pairs(self.members) do
        TriggerClientEventResource('removeFromParty', memberSource, source)
    end
end