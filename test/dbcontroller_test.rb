require 'minitest/autorun'
require 'pg'
require 'bcrypt'
require_relative '../lib/dbcontroller'
require 'minitest/reporters'
MiniTest::Reporters.use!

class DBControllerTest < MiniTest::Test
  def setup
    @db = DBController.new
  end

  def teardown
    begin
      ['games', 'coaches', 'players', 'teams', 'leagues', 'sports', 'admins'].each do |t|
        @db.conn.exec("DELETE FROM #{t}")
      end
      @db.disconnect
    rescue PG::ConnectionBad
    end
  end

  def test_connects
    assert @db
  end

  def test_disconnects
    @db.disconnect

    assert_equal true, @db.conn.finished?
  end

  def test_connects_to_lmt_test_db
    assert_equal 'lmt_test', @db.conn.db
  end

  def test_create_admin
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
  end

  def test_delete_admin
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    result = @db.delete_admin!(admin_id)
    result2 = @db.conn.exec("SELECT * FROM admins;")

    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result2.ntuples, 0 # No admins left in table
  end

  def test_change_admin_password
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    newpassword = BCrypt::Password.create('newpassword')
    result = @db.change_admin_password('user', newpassword)
    result2 = @db.conn.exec("SELECT * FROM admins;")

    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result.ntuples, 0
    assert_equal result2.ntuples, 1 # still only 1 user
  end

  def test_create_sport
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    result = @db.create_sport!(admin_id, 'Baseball')
    result2 = @db.conn.exec("SELECT * FROM sports;")

    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result2.ntuples, 1 # 1 sport added
  end

  def test_delete_sport
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    @db.create_sport!(admin_id, 'Baseball')
    result = @db.conn.exec("SELECT * FROM sports;")
    assert_equal result.ntuples, 1 # 1 sport added

    result = @db.delete_sport!(admin_id, 'Baseball')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK    
    
    result = @db.conn.exec("SELECT * FROM sports;")
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result.ntuples, 0 # sport deleted
  end

  def test_create_league
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    @db.create_sport!(admin_id, 'Baseball')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    sport_id = @db.sport_id(admin_id, 'Baseball')
    result = @db.create_league!(admin_id, sport_id, 'Baseball')
    result2 = @db.conn.exec("SELECT * FROM leagues;")

    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result2.ntuples, 1 # 1 league added
  end

  def test_delete_league
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    @db.create_sport!(admin_id, 'Baseball')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    sport_id = @db.sport_id(admin_id, 'Baseball')
    result = @db.create_league!(admin_id, sport_id, 'My Little League')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    result = @db.delete_league!(admin_id, 'My Little League')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK    

    result = @db.conn.exec("SELECT * FROM leagues;")
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result.ntuples, 0 # league deleted
  end

  def test_create_team
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    @db.create_sport!(admin_id, 'Baseball')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    sport_id = @db.sport_id(admin_id, 'Baseball')
    result = @db.create_league!(admin_id, sport_id, 'My Little League')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    league_id = @db.league_id(admin_id, 'My Little League')
    result = @db.create_team!(admin_id, league_id, 'Buffalo Bills')
    result2 = @db.conn.exec("SELECT * FROM teams;")
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result2.ntuples, 1 # team added
  end

  def test_delete_team
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    @db.create_sport!(admin_id, 'Baseball')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    sport_id = @db.sport_id(admin_id, 'Baseball')
    result = @db.create_league!(admin_id, sport_id, 'My Little League')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    league_id = @db.league_id(admin_id, 'My Little League')
    result = @db.create_team!(admin_id, league_id, 'Buffalo Bills')
    result2 = @db.conn.exec("SELECT * FROM teams;")
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result2.ntuples, 1 # team added

    @db.delete_team!(admin_id, 'Buffalo Bills')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    result = @db.conn.exec("SELECT * FROM teams;")
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result.ntuples, 0 # team removed
  end

  def test_create_player
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    result = @db.create_player!(admin_id, 'Billy Bob Thornton')
    result2 = @db.conn.exec("SELECT * FROM players;")

    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result2.ntuples, 1 # 1 sport added
  end

  def test_delete_player
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    @db.create_player!(admin_id, 'Billy Bob Thornton')
    result = @db.conn.exec("SELECT * FROM players;")
    assert_equal result.ntuples, 1 # 1 sport added

    result = @db.delete_player!(admin_id, 'Billy Bob Thornton')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK    
    
    result = @db.conn.exec("SELECT * FROM players;")
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result.ntuples, 0 # sport deleted
  end

  def test_create_coach
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    result = @db.create_coach!(admin_id, 'Vince Lombardi')
    result2 = @db.conn.exec("SELECT * FROM coaches;")

    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result2.ntuples, 1 # 1 sport added
  end

  def test_delete_coach
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    @db.create_coach!(admin_id, 'Vince Lombardi')
    result = @db.conn.exec("SELECT * FROM coaches;")
    assert_equal result.ntuples, 1 # 1 sport added

    result = @db.delete_coach!(admin_id, 'Vince Lombardi')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK    
    
    result = @db.conn.exec("SELECT * FROM coaches;")
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result.ntuples, 0 # sport deleted
  end

  def test_create_game
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    result = @db.create_game!(admin_id, '2021-05-28')
    result2 = @db.conn.exec("SELECT * FROM games;")

    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result2.ntuples, 1 # 1 sport added
  end

  def test_delete_game
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    @db.create_game!(admin_id, '2021-05-28')
    result = @db.conn.exec("SELECT * FROM games;")
    assert_equal result.ntuples, 1 # 1 sport added

    result = @db.delete_game!(admin_id, '2021-05-28')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK    
    
    result = @db.conn.exec("SELECT * FROM games;")
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result.ntuples, 0 # sport deleted
  end

  def test_player_roster
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    admin_id = @db.admin_id('user')
    # Create 3 players
    ['Billy', 'Joe', 'Mark'].each do |name|
      @db.create_player!(admin_id, name)
    end
    result = @db.conn.exec("SELECT * FROM players;")
    assert_equal result.ntuples, 3 # 3 players added
    # Create a team
    @db.create_sport!(admin_id, 'Baseball')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    sport_id = @db.sport_id(admin_id, 'Baseball')
    result = @db.create_league!(admin_id, sport_id, 'My Little League')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    league_id = @db.league_id(admin_id, 'My Little League')
    result = @db.create_team!(admin_id, league_id, 'Buffalo Bills')

    team_id = @db.team_id(admin_id, 'Buffalo Bills')
    p @db.player_roster(admin_id, team_id)
    assert false

  end
end
