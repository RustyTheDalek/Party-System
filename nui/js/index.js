var config;

fetch('/config.json')
    .then(response => {
        if (!response.ok) {
            throw new Error("HTTP error " + response.status);
        }
        return response.json();
    })
    .then(json => {
        onConfigLoaded(json)
    })
    .catch(function () {
        this.dataError = true;
    })

var uiActive = false
var socialWindow
var playerListContainer
var partyWindow
var partyListContainer
var notifications

var pendingInvites = {}

function onConfigLoaded(json) {
    config = json;

    addNotification(`Party System loaded!`, removeNotification, config.notificationTimeOutSeconds);
}

window.addEventListener("message", function (event) {

    switch (event.data.action) {
        case "sendPlayers":
            console.log('recieved players');
            AddPlayers(event.data.players, event.data.ownSource)
            break;
        case "playerDropped":
            RemovePlayer(event.data.source);
            break;
        case "playerJoining":
            AddPlayer(event.data.source, event.data.name);
            break;
        case "toggleSocial":
            toggleSocial(event.data.active);
            break;
        case "onPartyStart":
            SetPartyWindow("Your Party");
            break;
        case "recieveInvite":
            recievePlayerInvite(event.data.source, event.data.name);
            break;
        case "removeInvite":
            notifications.find(`#${event.data.source}`).slideUp("normal", function () {
                $(this).remove();
            });
            break;
        case "inviteRejected":
            onRejectedInvite(event.data.source, event.data.name);
            break;
        case "inviteTimedOut":
            onInviteTimedOut(event.data.source, event.data.name);
            break;
        case "playerJoinedParty":
            AddPartyMember(event.data.source, event.data.name, false, event.data.ownSource);

            if (event.data.hostName) {
                SetPartyWindow(event.data.hostName + "'s Party");
            }

            break;
        case "joinedParty":
            AddPartyMember(event.data.source, event.data.name);
            break;
        case "onRemoveFromParty":
            onRemoveFromParty(event.data.reason);
            break;
        case "hostRemovedPlayer":
            RemovePartyMember(event.data.source);
            SetPlayerInviteEnabled(event.data.source, true);
            break;
        case "removeFromParty":
            RemovePartyMember(event.data.source);
            break;
        case "playerAcceptedInvite":
            AddPartyMember(event.data.source, event.data.name, true);
            break;
        case "closeParty":
            partyWindow.addClass("hidden");
            SetPartyWindow("");
        case "currentMembers":
            AddPartyMembers(event.data.currentMembers, event.data.ownSource);
        default:
            console.warn(event.data.action + " not accounted for!");
            console.log(event);
            break;
    }
})

//On DOM load
$(function () {
    socialWindow = $('#social');
    partyWindow = $('#party');
    playerListContainer = $('#player-list tbody');
    partyListContainer = $('#party-list tbody');
    notifications = $('#notifications');

    if (typeof GetParentResourceName !== "function") {
        console.warn("GetParentResourceName is not defined");

        window.GetParentResourceName = function GetParentResourceName() {
            return "Party-System";
        }
    }

})

$(document).keypress(function (event) {
    switch (event.key) {
        case "o":
            $.post(`https://${GetParentResourceName()}/closeSocial`);
            toggleSocial(false);
            break;
    }
})

function AddPlayers(players, ownSource) {

    playerListContainer.empty();

    if (typeof (players) !== 'object' && Object.keys(players).length <= 0) {
        console.warn("Players list null or empty");
        return;
    } 

    for (const [source, player] of Object.entries(players)) {

        if (ownSource == player.source) {
            console.warn("Skipping self");
            continue;
        }
        
        AddPlayer(player.source, player.name);
    };
}

function AddPlayer(source, name) {

    console.log(`Adding Player ${name} with source ${source}`)

    let playerRow = $("<tr/>", {
        id: source
    });

    let playerSource = $("<td/>", {
        text: source,
        class: 'flex-center'
    });

    let playerData = $("<td/>");

    let playerName = $("<p/>", {
        class: "player-name",
        text: name
    });

    let actions = $("<div/>", {
        class: "actions flex-center"
    });

    let addButton = $("<button/>", {
        text: '+',
        value: source
    });

    let pendingIcon = $("<div/>", {
        class: "lds-dual-ring hidden"
    });

    addButton.on('click', invitePlayertoParty);

    actions.append(addButton);
    actions.append(pendingIcon);
    playerData.append(playerName);
    playerData.append(actions);

    playerRow.append(playerSource);
    playerRow.append(playerData);

    playerListContainer.append(playerRow).slideDown();
}

function RemovePlayer(source) {
    playerListContainer.find(`#${source}`).slideUp("normal", function () {
        $(this).remove();
    });
}

function AddPartyMembers(members, ownSource) {

    if (typeof (members) !== 'object' && Object.keys(members).length <= 0) {
        console.warn("Players list null or empty");
        return;
    } 

    members.forEach(member => {
        if (ownSource == member.source) {
            return;
        }

        AddPartyMember(member.source, member.name, false, ownSource);
    });
}

function AddPartyMember(source, name, owner = false, ownSource) {

    if (source == ownSource) {
        SetPlayerInviting(false);

        addNotification(`Joined party`, removeNotification, config.notificationTimeOutSeconds);

    } else {
        addNotification(`${name} Joined your party!`, removeNotification, config.notificationTimeOutSeconds);
    }

    if (owner) {

        clearTimeout(pendingInvites[source])
        pendingInvites[source] = null;
        setInvitePending(false);
        playerListContainer.find(`#${source} button`).prop('disabled', true).show().next().addClass("hidden");
    }

    console.log(`Adding Party Member ${name} with source ${source}`)

    //Indicate player in party in player list
    playerListContainer.find(`#${source} .player-name`).addClass('in-party');

    let playerRow = $("<tr/>", {
        id: source
    });

    let playerSource = $("<td/>", {
        text: source,
        class: 'flex-center'
    });

    let playerName = $("<td/>", {
        text: name
    });

    let actions = $("<div/>", {
        class: "actions flex-center"
    });

    if (owner) { //Add management buttons
        
        let removeButton = $("<button/>", {
            text: '✗',
            value: source
        });

        removeButton.on('click', removePlayerFromParty);
        actions.append(removeButton);
    }

    if(source == ownSource) { //Add leave button
        
        let removeButton = $("<button/>", {
            text: '➲',
            value: source
        });

        removeButton.on('click', leaveParty);
        actions.append(removeButton);
    }

    playerName.append(actions);

    playerRow.append(playerSource);
    playerRow.append(playerName);

    partyListContainer.append(playerRow);

    if (uiActive) {
        partyWindow.removeClass('hidden');
    }
}

//Sets whether a player can be invited
function SetPlayerInviteEnabled(source, enabled) {
    let playerListItem = playerListContainer.find(`#${source}`);

    console.log(playerListItem);
    console.log(playerListItem.find('button'));

    playerListItem.find('button').prop('disabled', !enabled);

    if (enabled) {
        playerListItem.find('.player-name').removeClass('in-party');
    } else {
        playerListItem.find('.player-name').addClass('in-party');
    }
}

//Set whether players can be invited
function SetPlayerInviting(active) {
    playerListContainer.find("tr").each(function () {
        $(this).find('button').prop('disabled', !active);
    });
}

function RemovePartyMember(source, reason) {

    console.log(`Removing party member with source ${source}`);

    let playerListItem = playerListContainer.find(`#${source}`);
    let playerListName = playerListItem.find('.player-name');
    
    console.log(playerListName);

    addNotification(`${playerListName.text()} was removed from your party`, removeNotification, config.notificationTimeOutSeconds);

    playerListName.removeClass('in-party');

    partyListContainer.find(`#${source}`).remove();

}

function onRemoveFromParty(reason) {

    addNotification(`You're no longer in the party reason: ${reason}`, removeNotification, config.notificationTimeOutSeconds);
    partyListContainer.empty();
    partyWindow.addClass('hidden');

    playerListContainer.find("tr").each(function () {
        $(this).find('button').prop('disabled', false);
    });
}

function toggleSocial(active) {

    uiActive = active;

    if (active) {
        socialWindow.removeClass('hidden');

        if (partyListContainer.children().length > 0) {
            partyWindow.removeClass('hidden');
        }

    } else {
        socialWindow.addClass('hidden');
        partyWindow.addClass('hidden');
    }
}

function SetPartyWindow(text) {
    partyWindow.find('.party-name').text(text);
}

function addNotification(message, timeoutCallback, timeoutSeconds, timeoutArg, id = '', secondaryContent = '') {
    console.log(`Creatiing notification`);

    let notificationItem = $("<li/>", {
        class: "window",
        id: id
    });

    let notificationText = $("<p/>", {
        text: message
    });

    let notificationTimeout = $("<div/>", {
        class: "timeoutBar",
        style: `transition: width ${timeoutSeconds}s linear`
    });

    notificationItem.append(notificationText);
    notificationItem.append(secondaryContent);
    notificationItem.append(notificationTimeout);

    notifications.append(notificationItem);

    notificationTimeout.width("0%");

    setTimeout(timeoutCallback.bind(notificationItem, timeoutArg), timeoutSeconds * 1000);

}

//#region Invited player functions 
function recievePlayerInvite(source, name) {
    console.log(`Recieved invite from ${name}`);

    let inviteButtons = $("<div/>", {
        class: "flex-center grid-gap-2 pt-2"
    });

    let acceptButton = $("<input/>", {
        type: "button",
        class: "accept",
        value: "✓"
    });

    let rejectButton = $("<input/>", {
        type: "button",
        class: "reject",
        value: "✗"
    });

    acceptButton.on('click', { source: source }, acceptInvite);
    rejectButton.on('click', { source: source }, rejectInvite);

    inviteButtons.append(acceptButton);
    inviteButtons.append(rejectButton);

    addNotification(`Recieved invite from ${name}`, removeInvite, config.inviteTimeoutSeconds, source, source, inviteButtons);

}

function removeNotification() {
    $(this).slideUp("normal", function () {
        $(this).remove();
    });
}

function removeInvite(inviteSource) {

    $.post(`https://${GetParentResourceName()}/invitedTimedOut`,
        JSON.stringify({
            inviteSource: inviteSource
        }));

    $(this).slideUp("normal", function () {
        $(this).remove();
    });
}

function acceptInvite(event) {

    closeInvite(event.target);
    console.log("Accepting invite from" + event.data.source)

    $.post(`https://${GetParentResourceName()}/acceptInvite`,
        JSON.stringify({
            acceptSource: event.data.source
        }));
}

function closeInvite(inviteButton) {
    let invite = $(inviteButton).closest(".window");
    let timeout = invite.find(".timeoutBar");

    $(timeout).css("transition", "none");

    $(invite).slideUp("normal", function () {
        $(this).remove();
    });
}

function rejectInvite(event) {

    closeInvite(event.target);

    $.post(`https://${GetParentResourceName()}/rejectInvite`,
        JSON.stringify({
            rejectSource: event.data.source
        }));
}

//#endregion

//#region Party Owner functions

function onRejectedInvite(source, name) {

    addNotification(`${name} rejected your invite!`, removeNotification, config.notificationTimeOutSeconds);

    clearTimeout(pendingInvites[source])
    pendingInvites[source] = null;
    setInvitePending(source, false);
}

function onInviteTimedOut(source, name) {

    addNotification(`${name} did not respond to your invite in time`, removeNotification, config.notificationTimeOutSeconds)
}

function invitePlayertoParty() {
    let sourceToInvite = +($(this).val());

    //Hide invite for particular user and show pending invite UI
    setInvitePending(sourceToInvite, true);

    pendingInvites[sourceToInvite] = setTimeout(function () {
        setInvitePending(sourceToInvite, false);
    }, config.inviteTimeoutSeconds * 1000);

    $.post(`https://${GetParentResourceName()}/invitePlayer`,
        JSON.stringify({
            inviteSource: sourceToInvite
        }));
}

//Sets the UI on player in list to to show whether invite is pending
function setInvitePending(source, active) {

    console.log("Setting Invite pending to " + active + " for source:" + source);

    let inviteButton = playerListContainer.find(`#${source} .actions button`)

    if (active) {
        inviteButton.hide();
        inviteButton.next().removeClass('hidden');
    } else {
        inviteButton.show();
        inviteButton.next().addClass('hidden');
    }
}

function removePlayerFromParty() {
    let sourceToRemove = +($(this).val());

    $(this).parent("tr").slideUp("normal", function () {
        $(this).remove();
    });

    $.post(`https://${GetParentResourceName()}/removePlayer`,
        JSON.stringify({
            sourceToRemove: sourceToRemove
        }));
}

function leaveParty() {
    $.post(`https://${GetParentResourceName()}/leaveParty`);
}

//#endregion