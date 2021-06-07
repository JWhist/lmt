require 'sinatra/base'
require 'pg'
require 'bcrypt'
#dbcontroller class

class DBController
  attr_reader :conn
  def initialize
     @conn = if Sinatra::Base.production?
              PG.connect(ENV['DATABASE_URL'])
            elsif Sinatra::Base.test?
              PG.connect(dbname: 'lmt_test') 
            else 
              PG.connect(dbname: 'lmt')
            end
  end

  def disconnect
    @conn.close
  end

  def validates_credentials?(username, password)
    return false if username.match?(' ') || password.match?(' ')
    return false if [username, password].any? { |cred| cred.strip == "" || cred.nil? }
    
    sql = "SELECT * FROM admins WHERE username = $1;"
    result = @conn.exec_params(sql, [username])

    result.ntuples == 0
  end

  def user_is_verified?(username, password_guess)
    sql = "SELECT * FROM admins WHERE username = $1;"
    result = @conn.exec_params(sql, [username])
    return false if result.ntuples == 0

    BCrypt::Password.new(result[0]["password"]) == password_guess
  end

  # --------------------------------------------------------------------
  # GET IDS
  # --------------------------------------------------------------------
  def admin_id(username)
    sql = <<~SQL
    SELECT id FROM admins WHERE username = $1;
    SQL
    result = @conn.exec_params(sql, [username])
    result[0]["id"].to_i
  end

  def sport_id(admin_id, name)
    sql = <<~SQL
    SELECT id FROM sports WHERE admin_id = $1 AND name = $2;
    SQL
    result = @conn.exec_params(sql, [admin_id, name])
    result[0]["id"].to_i
  end

  def league_id(admin_id, name)
    sql = <<~SQL
    SELECT id FROM leagues WHERE admin_id = $1 AND name = $2;
    SQL
    result = @conn.exec_params(sql, [admin_id, name])
    result[0]["id"].to_i
  end

  def team_id(admin_id, name)
    sql = <<~SQL
    SELECT id FROM teams WHERE admin_id = $1 AND name = $2;
    SQL
    result = @conn.exec_params(sql, [admin_id, name])
    result[0]["id"].to_i
  end

  def player_id(admin_id, name)
    sql = <<~SQL
    SELECT id FROM players WHERE admin_id = $1 AND name = $2;
    SQL
    result = @conn.exec_params(sql, [admin_id, name])
    result[0]["id"].to_i
  end

  def coach_id(admin_id, name)
    sql = <<~SQL
    SELECT id FROM coaches WHERE admin_id = $1 AND name = $2;
    SQL
    result = @conn.exec_params(sql, [admin_id, name])
    result[0]["id"].to_i
  end
  
  def game_id(admin_id, date)
    sql = <<~SQL
    SELECT id FROM games WHERE admin_id = $1 AND date = $2;
    SQL
    result = @conn.exec_params(sql, [name, date])
    result[0]["id"].to_i
  end
  # --------------------------------------------------------------------
  # ADMIN
  # --------------------------------------------------------------------
  def create_admin!(username, password)
    sql = <<~SQL
    INSERT INTO admins (username, password) VALUES
    ($1, $2);
    SQL
    @conn.exec_params(sql, [username, password])
  end

  def delete_admin!(id)
    sql = "DELETE FROM admins WHERE id = $1;"
    @conn.exec_params(sql, [id])
  end

  def change_admin_password(username, password)
    sql = <<~SQL
    UPDATE admins 
    SET password = $2
    WHERE username = $1;
    SQL
    @conn.exec_params(sql, [username, password])
  end
  # --------------------------------------------------------------------
  # SPORTS
  # --------------------------------------------------------------------
  def create_sport!(admin_id, name)
    sql = <<~SQL
    INSERT INTO sports (name, admin_id) VALUES ($1, $2);
    SQL

    @conn.exec_params(sql, [name, admin_id])
  end

  def delete_sport!(admin_id, name)
    sql = "DELETE FROM sports WHERE admin_id = $1 AND name = $2;"
    @conn.exec_params(sql, [admin_id, name])
  end

  def sports(admin_id)
    sql = "SELECT name FROM sports WHERE sports.admin_id = $1;"
    result = @conn.exec_params(sql, [admin_id])
    result.values
  end
  # --------------------------------------------------------------------
  # LEAGUES
  # --------------------------------------------------------------------
  def create_league!(admin_id, sport_id, name)
    sql = <<~SQL
    INSERT INTO leagues (name, sport_id, admin_id) VALUES ($1, $2, $3);
    SQL

    @conn.exec_params(sql, [name, sport_id, admin_id])
  end

  def delete_league!(admin_id, name)
    sql = "DELETE FROM leagues WHERE admin_id = $1 AND name = $2;"
    @conn.exec_params(sql, [admin_id, name])
  end

  def leagues(admin_id, sport_id)
    sql = 'SELECT leagues.id AS Id, leagues.name AS Name FROM leagues WHERE leagues.admin_id = $1 AND leagues.sport_id = $2;'
    result = @conn.exec_params(sql, [admin_id, sport_id])
    result.values
  end
  # --------------------------------------------------------------------
  # TEAMS
  # --------------------------------------------------------------------
  def create_team!(admin_id, league_id, name)
    sql = <<~SQL
    INSERT INTO teams (admin_id, league_id, name) VALUES ($1, $2, $3);
    SQL

    @conn.exec_params(sql, [admin_id, league_id, name])
  end

  def delete_team!(admin_id, name)
    sql = "DELETE FROM teams WHERE admin_id = $1 AND name = $2;"
    @conn.exec_params(sql, [admin_id, name])
  end

  def teams(admin_id, league_id)
    sql = 'SELECT teams.id AS Id, teams.name AS Name FROM teams WHERE teams.admin_id = $1 AND teams.league_id = $2;'
    result = @conn.exec_params(sql, [admin_id, league_id])
    result.values
  end
  # --------------------------------------------------------------------
  # PLAYERS
  # --------------------------------------------------------------------
  def create_player!(options = {})
    admin_id = options[:admin_id]
    name = options[:name]
    email = options[:email]
    phone = options[:phone]

    sql = <<~SQL
    INSERT INTO players (admin_id, name, email, phone) VALUES ($1, $2, $3, $4);
    SQL

    @conn.exec_params(sql, [admin_id, name, email, phone])
  end

  def delete_player!(admin_id, player_id)
    sql = "DELETE FROM players WHERE admin_id = $1 AND id = $2;"
    @conn.exec_params(sql, [admin_id, player_id])
  end

  def edit_player_info(options)
    admin_id = options[:admin_id]
    player_id = options[:player_id]
    name = options[:name]
    email = options[:email]
    phone = options[:phone]
    
    sql = <<~SQL
    UPDATE players
    SET name = $3, email = $4, phone = $5
    WHERE admin_id = $1 AND
    id = $2;
    SQL

    @conn.exec_params(sql, [admin_id, player_id, name, email, phone])
  end

  def assign_player_to_team(admin_id, player_id, team_id)
    sql = <<~SQL
    INSERT INTO teams_players (admin_id, player_id, team_id)
    VALUES ($1, $2, $3)
    SQL

    @conn.exec_params(sql, [admin_id, player_id, team_id])
  end

  def remove_player_from_team(admin_id, player_id, team_id)
    sql = <<~SQL
    DELETE FROM teams_players WHERE
    admin_id = $1 AND player_id = $2 AND team_id = $3;
    SQL

    @conn.exec_params(sql, [admin_id, player_id, team_id])
  end

  def players(admin_id)
    sql = "SELECT name, email, phone, id FROM players WHERE players.admin_id = $1;"
    result = @conn.exec_params(sql, [admin_id])
    result.values
  end
  # --------------------------------------------------------------------
  # COACHES
  # --------------------------------------------------------------------
  def create_coach!(options = {})
    admin_id = options[:admin_id]
    name = options[:name]
    email = options[:email]
    phone = options[:phone]
    
    sql = <<~SQL
    INSERT INTO coaches (admin_id, name, email, phone) VALUES ($1, $2, $3, $4);
    SQL

    @conn.exec_params(sql, [admin_id, name, email, phone])
  end

  def delete_coach!(admin_id, coach_id)
    sql = "DELETE FROM coaches WHERE admin_id = $1 AND id = $2;"
    @conn.exec_params(sql, [admin_id, coach_id])
  end

  def edit_coach_info(options = {})
    admin_id = options[:admin_id]
    coach_id = options[:coach_id]
    name = options[:name]
    email = options[:email]
    phone = options[:phone]
    
    sql = <<~SQL
    UPDATE coaches
    SET name = $3, email = $4, phone = $5
    WHERE admin_id = $1 AND
    id = $2;
    SQL

    @conn.exec_params(sql, [admin_id, coach_id, name, email, phone])
  end

  def assign_coach_to_team(admin_id, coach_id, team_id)
    sql = <<~SQL
    INSERT INTO teams_coaches (admin_id, coach_id, team_id)
    VALUES ($1, $2, $3)
    SQL

    @conn.exec_params(sql, [admin_id, coach_id, team_id])
  end

  def remove_coach_from_team(admin_id, coach_id, team_id)
    sql = <<~SQL
    DELETE FROM teams_coaches WHERE
    admin_id = $1 AND coach_id = $2 AND team_id = $3;
    SQL

    @conn.exec_params(sql, [admin_id, coach_id, team_id])
  end

  def coaches(admin_id)
    sql = 'SELECT name, email, phone, id FROM coaches WHERE coaches.admin_id = $1;'
    result = @conn.exec_params(sql, [admin_id])
    result.values
  end
  # --------------------------------------------------------------------
  # GAMES
  # --------------------------------------------------------------------
  def create_game!(options = {})
    admin_id = options[:admin_id]
    date = options[:date] || ''
    venue = options[:venue] || ''
    hs = options[:hs] || ''
    as = options[:as] || ''
    hid = options[:hid] 
    aid = options[:aid] 

    sql = <<~SQL
    INSERT INTO games (admin_id, gameday, venue, homescore, awayscore, hometeam_id, awayteam_id)
    VALUES ($1, $2, $3, $4, $5, $6, $7);
    SQL

    @conn.exec_params(sql, [admin_id, date, venue, hs, as, hid, aid])
  end

  def delete_game!(admin_id, date, team_id)
    sql = <<~SQL
    DELETE FROM games WHERE admin_id = $1 
    AND gameday = $2 
    AND (awayteam_id = $3
    OR hometeam_id = $3);
    SQL

    @conn.exec_params(sql, [admin_id, date, team_id])
  end
  # --------------------------------------------------------------------
  # GET PLAYER ROSTER
  # --------------------------------------------------------------------
  def player_roster(admin_id, team_id)
    sql = <<~SQL
    SELECT (SELECT name FROM players WHERE id = player_id) AS Name,
           (SELECT email FROM players WHERE id = player_id) AS Email,
           (SELECT phone FROM players WHERE id = player_id) AS Phone
    FROM teams_players WHERE
    admin_id = $1 AND
    team_id = $2;
    SQL

    result = @conn.exec_params(sql, [admin_id, team_id])
    result.values
  end
  # --------------------------------------------------------------------
  # GET COACH ROSTER
  # --------------------------------------------------------------------
  def coach_roster(admin_id, team_id)
    sql = <<~SQL
    SELECT (SELECT name FROM coaches WHERE id = coach_id) AS Name,
           (SELECT email FROM coaches WHERE id = coach_id) AS Email,
           (SELECT phone FROM coaches WHERE id = coach_id) AS Phone
    FROM teams_coaches WHERE
    admin_id = $1 AND
    team_id = $2;
    SQL

    result = @conn.exec_params(sql, [admin_id, team_id])
    result.values
  end
  # --------------------------------------------------------------------
  # GET TEAM SCHEDULE
  # --------------------------------------------------------------------
  def team_schedule(admin_id, team_id)
    sql = <<~SQL
    SELECT gameday as Date, venue as Location,  
    (SELECT name as Home FROM teams WHERE teams.id = hometeam_id) as Home, 
    (SELECT name as Away FROM teams WHERE teams.id = awayteam_id) as Away 
    FROM games JOIN teams ON
    games.awayteam_id = teams.id OR
    games.hometeam_id = teams.id WHERE
    games.admin_id = $1 AND
    teams.id = $2;
    SQL

    result = @conn.exec_params(sql, [admin_id, team_id])
    
    result.values
  end
  # --------------------------------------------------------------------
  # GET LEAGUE SCHEDULE
  # --------------------------------------------------------------------
  def league_schedule(admin_id, league_id)
    games = []
    teams = teams(admin_id, league_id) # array of team IDs and names
    teams.each do |team|
      team_schedule(admin_id, team[0]).each do |game|
        games << game
      end
    end
    games.uniq.sort_by { |x| x[0] }
  end
end