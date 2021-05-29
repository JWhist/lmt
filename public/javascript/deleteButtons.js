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
  request.addEventListener('load', e => location = '/admin');
  request.send();
}