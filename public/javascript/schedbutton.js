function getSchedule() {
  const leagueMenu = document.getElementById('leagues');
  let league = leagueMenu.value;
  
  if (!league) return;
  location = `/league/schedule?league=${league}`;
}
