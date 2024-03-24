var config;

fetch('/config.json')
    .then(response => {
        if (!response.ok) {
            throw new Error("HTTP error " + response.status);
        }
        return response.json();
    })
    .then(json => {
        config = json
    })
    .catch(function () {
        this.dataError = true;
    })

var uiActive = false
var socialWindow
var playerListContainer
var invites

window.addEventListener("message", function (event) {
    console.log(event);

    switch (event.data.action) {
        case "sendPlayers":
            console.log('sending players');
            AddPlayers(event.data.players, event.data.ownSource)
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
        case "inviteRejected":
            onRejectedInvite(event.data.source);
            break;
        case "inviteTimedOut":
            reEnableInvite(event.data.source);
            break;
        case "playerJoinedParty":
            AddPartyMember(event.data.source, event.data.ownSource, event.data.name, event.data.owner);
            break;
        case "onRemoveFromParty":
            onRemoveFromParty();
            break;
        case "removeFromParty":
            RemovePartyMember(event.data.source);
            break;
        case "playerAcceptedInvite":
            AddPartyMember(event.data.source, event.data.name, true);
        default:
            console.warn(event.data.action = " not accounted for!");
            break;
    }
})

//On DOM load
$(function () {
    socialWindow = $('#social');
    partyWindow = $('#party');
    playerListContainer = $('#player-list tbody');
    partyListContainer = $('#party-list tbody');
    invites = $('#party-invites');

    if(typeof GetParentResourceName !== "function") {
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

    if (typeof (players) !== 'object' && Object.keys(players).length <= 0) return;
    players.forEach(player => {

        // if(ownSource == player.source) return;

        AddPlayer(player.source, player.name);
    });
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

    let playerName = $("<td/>", {
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
    playerName.append(actions);

    playerRow.append(playerSource);
    playerRow.append(playerName);

    playerListContainer.append(playerRow);
}

function RemovePlayer(source) {
    playerListContainer.find(`#${source}`).slideUp("normal", function () {
        $(this).remove();
    });
}

function AddPartyMember(source, name, owner = false) {

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

    if (owner) { //Add management buttons
        let actions = $("<div/>", {
            class: "actions flex-center"
        });

        let removeButton = $("<button/>", {
            text: '✗',
            value: source
        });

        removeButton.on('click', removePlayerFromParty);

        actions.append(removeButton);

        playerName.append(actions);
    }

    playerRow.append(playerSource);
    playerRow.append(playerName);

    partyListContainer.append(playerRow);

    if(uiActive) {
        partyWindow.removeClass('hidden');
    }
}
}

function RemovePartyMember(source) {

    let playerListItem = playerListContainer.find(`#${source}`);
    let playerListName = playerListItem.find('.player-name');

    playerListName.addClass('in-party');

    partyListContainer.find(`${source}`).remove();
    
}

function onRemoveFromParty() {
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

//#region Invited player functions 
function recievePlayerInvite(source, name) {
    console.log(`Recieved invite from ${name}`);

    let inviteItem = $("<li/>", {
        class: "window"
    });

    let inviteText = $("<p/>", {
        text: " has invited you to a party, would you like to join?"
    });

    let inviteName = $("<span/>", {
        class: "name",
        text: name
    });

    inviteText.prepend(inviteName);

    let inviteButtons = $("<div/>", {
        class: "flex-center grid-gap-2"
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

    let inviteTimeout = $("<div/>", {
        class: "timeoutBar",
        style: `transition: width ${config.inviteTimeoutSeconds}s linear`
    });

    acceptButton.on('click', { source: source }, acceptInvite);
    rejectButton.on('click', { source: source }, rejectInvite);

    inviteButtons.append(acceptButton);
    inviteButtons.append(rejectButton);

    inviteItem.append(inviteText);
    inviteItem.append(inviteButtons);
    inviteItem.append(inviteTimeout);

    invites.append(inviteItem);

    inviteTimeout.width("0%");

    setTimeout(removeInvite.bind(null, inviteItem, source), config.inviteTimeoutSeconds * 1000);

}

function removeInvite(invite, inviteSource) {

    $.post(`https://${GetParentResourceName()}/invitedTimedOut`,
        JSON.stringify({
            inviteSource: inviteSource
        }));

    $(invite).slideUp("normal", function () {
        $(this).remove();
    });
}

function acceptInvite(event) {

    closeInvite(event.target);
    console.log(event);

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

function onRejectedInvite(source) {
    reEnableInvite(source);
}

function reEnableInvite(source) {
    playerListContainer.find(`#${source} .actions button`).show();
    playerListContainer.find(`#${source} .actions .lds-dual-ring`).addClass('hidden');
}

function invitePlayertoParty() {
    let sourceToInvite = +($(this).val());

    //Hide invite for particular user and show pending invite UI
    $(this).hide();
    $(this).next().removeClass('hidden');
    console.log("Inviting player");

    setTimeout(function () {
        reEnableInvite(source);
    }, config.inviteTimeoutSeconds * 1000);

    $.post(`https://${GetParentResourceName()}/invitePlayer`,
        JSON.stringify({
            inviteSource: sourceToInvite
        }));
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

//#endregion