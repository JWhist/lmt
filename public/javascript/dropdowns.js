document.addEventListener('DOMContentLoaded', () => {
  const sports = document.getElementById("sports");
  sports.addEventListener('input', (event) => {
    event.preventDefault();
    const options = event.target.options;
    const res = document.querySelector('#leagues');
    let request = new XMLHttpRequest();
                
    request.open('POST', `/leagues?sport=${options[event.target.selectedIndex].value}`);
    request.addEventListener("load", (e) => {
      e.preventDefault();
      let options = JSON.parse(request.responseText);
      console.log(options);
      if (res.innerHTML) res.innerHTML = '';
      let op = document.createElement('option');
      op.value = '';
      op.innerText = 'Please select a League';
      res.appendChild(op);
      res.size = options.length;
      options.forEach((option, i) => {
        let op = document.createElement('option');
        op.value = option[1];
        op.innerText = op.value;
        res.appendChild(op);
      });
      console.log('A');
      makeTeams();
      makeTeamsTwo();
    });
  
    request.send();
        
  });
});
  
function makeTeams() {
  const leagues = document.getElementById("leagues");
  leagues.addEventListener('input', (event) => {
    event.preventDefault();
    const options = event.target.options;
    const res = document.querySelector('#teams');
    let request = new XMLHttpRequest();
              
    request.open('POST', `/teams?league=${options[event.target.selectedIndex].value}`);
    request.addEventListener("load", (e) => {
      e.preventDefault();
      let options = JSON.parse(request.responseText);
      if (res.innerHTML) res.innerHTML = '';
      let op = document.createElement('option');
      op.value = '';
      op.innerText = 'Please select a Team';
      res.appendChild(op);
      options.forEach((option, i) => {
        let op = document.createElement('option');
        op.value = option[1];
        op.innerText = op.value;
        res.appendChild(op);
      });
      console.log('B');
      makeGames();
      makeTeamsTwo();
    });

    request.send();
  });
}
function makeTeamsTwo() {
  const leagues = document.getElementById("leagues");
  leagues.addEventListener('input', (event) => {
    event.preventDefault();
    const options = event.target.options;
    const res = document.querySelector('#teams2');
    let request = new XMLHttpRequest();
              
    request.open('POST', `/teams?league=${options[event.target.selectedIndex].value}`);
    request.addEventListener("load", (e) => {
      e.preventDefault();
      let options = JSON.parse(request.responseText);
      if (res.innerHTML) res.innerHTML = '';
      let op = document.createElement('option');
      op.value = '';
      op.innerText = 'Please select a Team';
      res.appendChild(op);
      options.forEach((option, i) => {
        let op = document.createElement('option');
        op.value = option[1];
        op.innerText = op.value;
        res.appendChild(op);
      });
      console.log('B');
    });

    request.send();
  });
}
  
function makeGames() {
  const teams = document.getElementById("teams");

  teams.addEventListener('input', (event) => {
    event.preventDefault();
    const options = event.target.options;
    const res = document.querySelector('#games');
    let request = new XMLHttpRequest();
              
    request.open('POST', `/games?team=${options[event.target.selectedIndex].value}`);

    request.addEventListener("load", (e) => {
      e.preventDefault();
      let options = JSON.parse(request.responseText);
      console.log(options);
      let l = options[1].length
      if (res.innerHTML) res.innerHTML = '';
      res.size = l+1;

      options[1].forEach((game, i) => {
        let op = document.createElement('option');
        op.value = game[0];
        op.innerText = `Date: ${game[0]}\nLocation: ${game[1]}\nHome: ${game[2]}\n Away: ${game[3]}\n`;
        res.appendChild(op);
      });
    });
    request.send();
  });
}

function fillDates() {
  const teams = document.getElementById("teams");

  teams.addEventListener('input', (event) => {
    event.preventDefault();
    const options = event.target.options;
    const res = document.querySelector("#deldate");
    let request = new XMLHttpRequest();
              
    request.open('POST', `/games?team=${options[event.target.selectedIndex].value}`);

    request.addEventListener("load", (e) => {
      e.preventDefault();
      let options = JSON.parse(request.responseText);
      console.log(options);

      if (res.innerHTML) res.innerHTML = '';
      let op = document.createElement('option');
      op.value = '';
      op.innerText = 'Please select a Team';
      res.appendChild(op);
      res.size = options[1].length;
      options[1].forEach((game, i) => {
        let op = document.createElement('option');
        op.value = game[0];
        op.innerText = op.value;
        res.appendChild(op);
      });
    });
    console.log('C');
    request.send();
  });
}