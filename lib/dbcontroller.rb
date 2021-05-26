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
    sql = "DELETE FROM sports WHERE (admin_id = $1 AND name = $2);"
    @conn.exec_params(sql, [admin_id, name])
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
  # --------------------------------------------------------------------
  # PLAYERS
  # --------------------------------------------------------------------
  def create_player!(admin_id, name)
    sql = <<~SQL
    INSERT INTO players (admin_id, name) VALUES ($1, $2);
    SQL

    @conn.exec_params(sql, [admin_id, name])
  end

  def delete_player!(admin_id, name)
    sql = "DELETE FROM players WHERE admin_id = $1 AND name = $2;"
    @conn.exec_params(sql, [admin_id, name])
  end
  # --------------------------------------------------------------------
  # COACHES
  # --------------------------------------------------------------------
  def create_coach!(admin_id, name)
    sql = <<~SQL
    INSERT INTO coaches (admin_id, name) VALUES ($1, $2);
    SQL

    @conn.exec_params(sql, [admin_id, name])
  end

  def delete_coach!(admin_id, name)
    sql = "DELETE FROM coaches WHERE admin_id = $1 AND name = $2;"
    @conn.exec_params(sql, [admin_id, name])
  end
  # --------------------------------------------------------------------
  # GAMES
  # --------------------------------------------------------------------
  def create_game!(admin_id, date)
    sql = <<~SQL
    INSERT INTO games (admin_id, gameday) VALUES ($1, $2);
    SQL

    @conn.exec_params(sql, [admin_id, date])
  end

  def delete_game!(admin_id, date)
    sql = "DELETE FROM games WHERE admin_id = $1 AND gameday = $2;"
    @conn.exec_params(sql, [admin_id, date])
  end
  # --------------------------------------------------------------------
  # GET PLAYER ROSTER
  # --------------------------------------------------------------------
  def player_roster(admin_id, team_id)
    sql = <<~SQL
    SELECT players.name AS Name, players.email AS Email, players.phone AS Phone
    FROM players JOIN teams ON
    players.admin_id = teams.admin_id
    WHERE
    players.admin_id = $1
    AND
    teams.id = $2;
    SQL

    result = @conn.exec_params(sql, [admin_id, team_id])
    result.values
  end
end