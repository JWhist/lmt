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
    fillGames();
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
    console.log(options);
    let l = options[1].length
    if (res.innerHTML) res.innerHTML = '';
    res.size = l + 1;

    options[1].forEach((game, i) => {
      let op = document.createElement('option');
      op.value = game[0];
      op.innerText = `\nDate: ${game[0]}\nLocation: ${game[1]}\nHome: ${game[2]}\n Away: ${game[3]}\n`;
      res.appendChild(op);
    });
  });
  request.send();
}