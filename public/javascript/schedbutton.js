function getSchedule() {
  const leagueMenu = document.getElementById('leagues');
  let league = leagueMenu.value;
  
  if (!league) return;
  window.open(`/league/schedule?league=${league}`, '_blank');
}

function getRoster() {
  const teamMenu = document.getElementById('teams');
  let team = teamMenu.value;

  if (!team) return;
  window.open(`/team/roster?team=${team}`, '_blank');
}

function assignPlayerToTeam() {
  const playersMenu = document.getElementById('players');
  const teamsMenu = document.getElementById('teams');
  const player_id = playersMenu.value;
  const team = teamsMenu.value;

  let request = new XMLHttpRequest();

  request.open('POST', `/player/assign?player_id=${player_id}&team=${team}`);

  request.addEventListener('load', (e) => {
    e.preventDefault();
  });

  request.send();
}
function assignCoachToTeam() {
  const coachesMenu = document.getElementById('coaches');
  const teamsMenu = document.getElementById('teams');
  const coach_id = coachesMenu.value;
  const team = teamsMenu.value;

  let request = new XMLHttpRequest();

  request.open('POST', `/coach/assign?coach_id=${coach_id}&team=${team}`);

  request.addEventListener('load', (e) => {
    e.preventDefault();
  });

  request.send();
}
function removePlayerFromTeam() {
  const playersMenu = document.getElementById('players');
  const teamsMenu = document.getElementById('teams');
  const player_id = playersMenu.value;
  const team = teamsMenu.value;

  let request = new XMLHttpRequest();

  request.open('POST', `/player/remove?player_id=${player_id}&team=${team}`);

  request.addEventListener('load', (e) => {
    e.preventDefault();
  });

  request.send();
}
function removeCoachFromTeam() {
  const coachesMenu = document.getElementById('coaches');
  const teamsMenu = document.getElementById('teams');
  const coach_id = coachesMenu.value;
  const team = teamsMenu.value;

  if (coach_id === undefined || team === undefined) return;

  let request = new XMLHttpRequest();

  request.open('POST', `/coach/remove?coach_id=${coach_id}&team=${team}`);

  request.addEventListener('load', (e) => {
    e.preventDefault();
  });

  request.send();
}