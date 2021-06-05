document.addEventListener('DOMContentLoaded', () => {
  fillPlayers();
  fillCoaches();
});

function deleteSport() {
  let sportMenu = document.getElementById("sports");
  let sport = sportMenu.value;

  let request = new XMLHttpRequest();
  request.open('POST', `/sport/delete?sport=${sport}`);
  request.addEventListener('load', e => location = '/admin');
  request.send();
}

function deleteLeague() {
  let leaguesMenu = document.getElementById("leagues");
  let league = leaguesMenu.value;

  let request = new XMLHttpRequest();
  request.open('POST', `/league/delete?league=${league}`);
  request.addEventListener('load', e => location = '/admin');
  request.send();
}

function deleteTeam() {
  let teamsMenu = document.getElementById("teams");
  let team = teamsMenu.value;

  let request = new XMLHttpRequest();
  request.open('POST', `/team/delete?team=${team}`);
  request.addEventListener('load', e => location = '/admin');
  request.send();
}

function deleteGame() {
  let teamsMenu = document.getElementById("teams");
  let team = teamsMenu.value;
  let gameMenu = document.getElementById("games");
  let date = gameMenu.value;
  
  let request = new XMLHttpRequest();
  request.open('POST', `/game/delete?team=${team}&date=${date}`);
  request.addEventListener('load', (e) => {
    e.preventDefault();
    let message = document.getElementById('msg');
    message.innerText = 'Game has been deleted';
    setTimeout(() => {
      message.innerText = '';
    }, 2000);
    fillGames();
  })
  request.send();
}

function deletePlayer() {
  let playersMenu = document.getElementById("players");
  let player_id = playersMenu.value;
  
  let request = new XMLHttpRequest();
  request.open('POST', `/player/delete?player_id=${player_id}`);
  request.addEventListener('load', (e) => {
    e.preventDefault();
    let message = document.getElementById('msg');
    message.innerText = 'Player has been deleted';
    setTimeout(() => {
      message.innerText = '';
    }, 2000);
    fillPlayers();
  })
  request.send();
}
function deleteCoach() {
  const coachesMenu = document.getElementById("coaches");
  let coach_id = coachesMenu.value;
  
  let request = new XMLHttpRequest();
  request.open('POST', `/coach/delete?coach_id=${coach_id}`);
  request.addEventListener('load', (e) => {
    e.preventDefault();
    let message = document.getElementById('msg');
    message.innerText = 'Coach has been deleted';
    setTimeout(() => {
      message.innerText = '';
    }, 2000);
    fillCoaches();
  })
  request.send();
}
function fillGames() {
  const teamsMenu = document.getElementById("teams");
  let team = teamsMenu.value;
  const res = document.querySelector('#games');
  let request = new XMLHttpRequest();
            
  request.open('POST', `/games?team=${team}`);

  request.addEventListener("load", (e) => {
    e.preventDefault();
    let options = JSON.parse(request.responseText);
    let l = options[1].length
    if (res.innerHTML) res.innerHTML = '';
    res.size = l + 1;

    options[1].forEach((game, i) => {
      let op = document.createElement('option');
      op.value = game[0];
      op.innerText = `Date: ${game[0]}\nLocation: ${game[1]}\nHome: ${game[2]}\n Away: ${game[3]}\n`;
      res.appendChild(op);
    });
  });
  request.send();
}


function fillPlayers() {
  const res = document.querySelector('#players');
  let request = new XMLHttpRequest();
            
  request.open('POST', '/players');

  request.addEventListener("load", (e) => {
    e.preventDefault();
    let players = JSON.parse(request.responseText);
    if (res.innerHTML) res.innerHTML = '';
    res.size = players.length + 1;

    players.forEach(player => {
      let op = document.createElement('option');
      op.value = player[3];
      op.innerText = `Name: ${player[0]}\nEmail: ${player[1]}\nPhone: ${player[2]}`;
      res.appendChild(op);
    });
  });
  request.send();
}
function fillCoaches() {
  const res = document.querySelector('#coaches');
  let request = new XMLHttpRequest();
            
  request.open('POST', '/coaches');

  request.addEventListener("load", (e) => {
    e.preventDefault();
    let coaches = JSON.parse(request.responseText);
    if (res.innerHTML) res.innerHTML = '';
    res.size = coaches.length + 1;

    coaches.forEach(coach => {
      let op = document.createElement('option');
      op.value = coach[3];
      op.innerText = `Name: ${coach[0]}\nEmail: ${coach[1]}\nPhone: ${coach[2]}`;
      res.appendChild(op);
    });
  });
  request.send();
}