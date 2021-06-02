CREATE TABLE admins (
  id SERIAL PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL
);

CREATE TABLE sports (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  admin_id INTEGER REFERENCES admins (id)
  ON DELETE CASCADE
);

CREATE TABLE leagues (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  sport_id INTEGER REFERENCES sports (id)
  ON DELETE CASCADE,
  admin_id INTEGER REFERENCES admins (id)
  ON DELETE CASCADE
);

CREATE TABLE teams (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  league_id INTEGER REFERENCES leagues (id)
  ON DELETE CASCADE,
  admin_id INTEGER REFERENCES admins (id)
  ON DELETE CASCADE
);

CREATE TABLE players (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  admin_id INTEGER REFERENCES admins (id)
  ON DELETE CASCADE
);

CREATE TABLE coaches (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  admin_id INTEGER REFERENCES admins (id)
  ON DELETE CASCADE
);

CREATE TABLE games (
  id SERIAL PRIMARY KEY,
  gameday DATE,
  venue TEXT,
  homescore TEXT,
  awayscore TEXT,
  hometeam_id INTEGER REFERENCES teams (id)
  ON DELETE CASCADE,
  awayteam_id INTEGER REFERENCES teams (id)
  ON DELETE CASCADE,
  admin_id INTEGER REFERENCES admins (id)
  ON DELETE CASCADE
);

CREATE TABLE teams_players (
  team_id INTEGER REFERENCES teams (id)
  ON DELETE CASCADE,
  player_id INTEGER REFERENCES players (id)
  ON DELETE CASCADE,
  admin_id INTEGER REFERENCES admins (id)
);

CREATE TABLE teams_coaches (
  team_id INTEGER REFERENCES teams (id)
  ON DELETE CASCADE,
  coach_id INTEGER REFERENCES coaches (id)
  ON DELETE CASCADE,
  admin_id INTEGER REFERENCES admins (id)
);
