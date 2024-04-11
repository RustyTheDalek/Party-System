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
    for index, invite in pairs(self.invited) do
        if (GetGameTimer() - invite.timeInvited > Config.data.inviteTimeoutSeconds * 1000) then
            print("Invited timed out for source " .. index)
            TriggerClientEventResource('inviteTimedOut', self.owner, index, GetPlayerName(index))
            self.invited[index] = nil
        end
    end

    self.empty = (self.members == nil and self.invited == nil) or
    (getTableSize(self.members) == 0 and getTableSize(self.invited) == 0)
end

function Party:Close(reason)
    TriggerClientEventResource('closeParty', self.owner)

    self:TriggerClientEventForInvited('removeInvite', self.owner)
    self:TriggerClientEventForMembers('onRemoveFromParty', reason)
end

function Party:InvitePlayer(source, invitingSource, invitingName)
    if (self.invited[source] == nil) then
        print("Can invite " .. source)

        TriggerClientEventResource('onRecieveInvite', source, invitingSource, invitingName)

        self.invited[source] = { timeInvited = GetGameTimer() }
    else
        print("Already invited")
    end
end

function Party:PlayerInParty(source)
    if (self.members[source] ~= nil) then
        print("player in party already")
        return true
    end

    return false
end

function Party:RejectInvite(source, sourceRejected)
    self.invited[source] = nil
    TriggerClientEventResource('inviteRejected', sourceRejected, source, GetPlayerName(source))
end

function Party:AcceptInvite(sourceAccepted, hostSource)
    self.invited[sourceAccepted] = nil

    self:AddPlayer(sourceAccepted)

    local acceptedName = GetPlayerName(sourceAccepted)
    local hostName = GetPlayerName(hostSource)

    --Tell owner
    TriggerClientEventResource('playerAcceptedInvite', self.owner, sourceAccepted, acceptedName)
    --Tell all members
    self:TriggerClientEventForMembers('playerJoinedParty', sourceAccepted, acceptedName, hostName)

    --Tell Player that joined
    TriggerClientEventResource('joinedParty', sourceAccepted, hostSource, self.members)
end

function Party:AddPlayer(sourceAccepted)
    self.members[sourceAccepted] =  {
        source = sourceAccepted,
        name = GetPlayerName(sourceAccepted)
    }
end

function Party:RemovePlayer(source, reason)
    if (self.invited[source] ~= nil) then
        print("Removing pending invite")
        self.invited[source] = nil
    end

    TriggerClientEventResource('hostRemovedPlayer', self.owner, source)
    self.members[source] = nil
    TriggerClientEventResource('onRemoveFromParty', source, reason)
    self:TriggerClientEventForMembers('removeFromParty', source)
end

function Party:TriggerClientEventForMembers(event, ...)
    print("Trigger Event " .. event .. " For all members")
    for _, member in pairs(self.members) do
        print("Trigger Event For source " .. member.name)
        TriggerClientEventResource(event, member.source, ...)
    end
end

function Party:GetPartySources()
    local sources = {}
    sources[self.owner] = self.owner
    for _, member in pairs(self.members) do
        sources[source] = member.source
    end
    return sources
end

function Party:TriggerClientEventForInvited(event, ...)
    print("Trigger Event " .. event .. " For all invited")
    for _, member in pairs(self.members) do
        print("Trigger Event For source " .. member.name)
        TriggerClientEventResource(event, member.source, ...)
    end
end
