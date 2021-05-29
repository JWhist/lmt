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