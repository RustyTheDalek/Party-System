
var socialWindow
var playerListContainer

window.addEventListener("message", function (event) {
    console.log(event);

    switch(event.data.action) {
        case "sendPlayers":
            console.log('sending players');
            AddPlayers(event.data.players, event.data.ownSource)
            break;
        case "toggleSocial":
            toggleSocial(event.data.active);
            break;
    }
})

//On DOM load
$(function () {
    socialWindow = $('#social');
    playerListContainer = $('#player-list tbody');
})

function AddPlayers(players, ownSource) {

    console.log(players);
    console.log(typeof(players));

    if(typeof(players) !== 'object' && Object.keys(players).length <= 0) return;
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
        text: name
    });

    // playerName.fitText(0.1);

    let playerButtons = $("<div/>");

    let addButton = $("<button/>", {
        text: '+'
    });

    addButton.on('click', addPlayertoParty);

    playerButtons.append(addButton);
    playerName.append(playerButtons);

    playerRow.append(playerSource);
    playerRow.append(playerName);

    playerListContainer.append(playerRow);
}

function addPlayertoParty() {
    console.log('Adding player');
}

function toggleSocial(active) {

    console.log('toggling social');

    if(active) {
        socialWindow.removeClass('hidden');
    } else {
        socialWindow.addClass('hidden');
    }
}