
var playerListContainer 

//On DOM load
$(function () {
    
    playerListContainer = $('#player-list tbody');

    AddPlayer(1, 'Rusty');
    AddPlayer(2, 'Someonewithalongname69Someonewithalongname69Someonewithalongname69');
    AddPlayer(3, 'JC');
    AddPlayer(4, 'MasterSJT');

    for (let index = 0; index < 50; index++) {
        AddPlayer(index, 'Rusty:' + index);
    }
})

function AddPlayer(source, name) {

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

    playerButtons.append(addButton);
    playerName.append(playerButtons);

    playerRow.append(playerSource);
    playerRow.append(playerName);

    playerListContainer.append(playerRow);
}