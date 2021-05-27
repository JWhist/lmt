CREATE TABLE admins (
  id SERIAL PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL
);

CREATE TABLE sports (
  id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  admin_id INTEGER REFERENCES admins (id)
);

CREATE TABLE leagues (
  id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  sport_id INTEGER REFERENCES sports (id),
  admin_id INTEGER REFERENCES admins (id)
);

CREATE TABLE teams (
  id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  league_id INTEGER REFERENCES leagues (id),
  admin_id INTEGER REFERENCES admins (id)
);

CREATE TABLE players (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  admin_id INTEGER REFERENCES admins (id)
);

CREATE TABLE coaches (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  admin_id INTEGER REFERENCES admins (id)
);

CREATE TABLE games (
  id SERIAL PRIMARY KEY,
  gameday DATE,
  venue TEXT,
  homescore TEXT,
  awayscore TEXT,
  hometeam_id INTEGER REFERENCES teams (id),
  awayteam_id INTEGER REFERENCES teams (id),
  admin_id INTEGER REFERENCES admins (id)
);

CREATE TABLE teams_players (
  team_id INTEGER REFERENCES teams (id),
  player_id INTEGER REFERENCES players (id),
  admin_id INTEGER REFERENCES admins (id)
);

CREATE TABLE teams_coaches (
  team_id INTEGER REFERENCES teams (id),
  coach_id INTEGER REFERENCES coaches (id),
  admin_id INTEGER REFERENCES admins (id)
);
