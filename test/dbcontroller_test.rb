require 'minitest/autorun'
require 'pg'
require 'bcrypt'
require_relative '../lib/dbcontroller'
require 'minitest/reporters'
MiniTest::Reporters.use!

class DBControllerTest < MiniTest::Test
  def setup
    counter = 0
    begin
      @db = DBController.new
    rescue PG::ConnectionBad
      counter += 1
      retry if counter < 4
    end
  end

  def teardown
    counter = 0
    begin
      ['teams_players', 'teams_coaches', 'games', 'coaches', 'players', 
        'teams', 'leagues', 'sports', 'admins'].each do |t|
        @db.conn.exec("DELETE FROM #{t}")
      end
      @db.disconnect
    rescue PG::ConnectionBad
      counter += 1
      retry if counter < 4
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
    result = @db.create_player!({admin_id: admin_id, name: 'Billy Bob Thornton'})
    result2 = @db.conn.exec("SELECT * FROM players;")

    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result2.ntuples, 1 # 1 player added
  end

  def test_delete_player
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    @db.create_player!({admin_id: admin_id, name: 'Billy Bob Thornton'})
    result = @db.conn.exec("SELECT * FROM players;")
    assert_equal result.ntuples, 1 # 1 player added

    result = @db.delete_player!(admin_id, 'Billy Bob Thornton')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK    
    
    result = @db.conn.exec("SELECT * FROM players;")
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result.ntuples, 0 # player deleted
  end

  def test_edit_player_info
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    result = @db.create_player!({admin_id: admin_id, name: 'Billy Bob Thornton'})
    result2 = @db.conn.exec("SELECT * FROM players;")
    player_id = @db.player_id(admin_id, 'Billy Bob Thornton')

    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result2.ntuples, 1 # 1 player added

    options = { admin_id: admin_id, player_id: player_id, name: 'Jim Smith', 
                email: 'Me@Testing.com', phone: '123-456-7890' }

    result = @db.edit_player_info(options)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    result2 = @db.conn.exec("SELECT * FROM players;")
    assert_equal result2.ntuples, 1 # still only 1 player
    assert_equal result2[0]['name'], 'Jim Smith'
  end

  def test_assign_player_to_team
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    result = @db.create_player!({admin_id: admin_id, name: 'Billy Bob Thornton'})
    result2 = @db.conn.exec("SELECT * FROM players;")

    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result2.ntuples, 1 # 1 player added

    player_id = @db.player_id(admin_id, 'Billy Bob Thornton')
    @db.create_sport!(admin_id, 'Baseball')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    sport_id = @db.sport_id(admin_id, 'Baseball')
    result = @db.create_league!(admin_id, sport_id, 'My Little League')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    league_id = @db.league_id(admin_id, 'My Little League')
    result = @db.create_team!(admin_id, league_id, 'Buffalo Bills')
    team_id = @db.team_id(admin_id, 'Buffalo Bills')

    result = @db.conn.exec("SELECT * FROM teams;")
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result.ntuples, 1 # team added

    result = @db.assign_player_to_team(admin_id, player_id, team_id)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    result = @db.conn.exec("SELECT * FROM teams_players;")
    assert_equal result.ntuples, 1 # player added
  end

  def test_remove_player_from_team
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    result = @db.create_player!({admin_id: admin_id, name: 'Billy Bob Thornton'})
    result2 = @db.conn.exec("SELECT * FROM players;")

    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result2.ntuples, 1 # 1 player added

    player_id = @db.player_id(admin_id, 'Billy Bob Thornton')
    @db.create_sport!(admin_id, 'Baseball')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    sport_id = @db.sport_id(admin_id, 'Baseball')
    result = @db.create_league!(admin_id, sport_id, 'My Little League')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    league_id = @db.league_id(admin_id, 'My Little League')
    result = @db.create_team!(admin_id, league_id, 'Buffalo Bills')
    team_id = @db.team_id(admin_id, 'Buffalo Bills')

    result = @db.conn.exec("SELECT * FROM teams;")
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result.ntuples, 1 # team added

    result = @db.assign_player_to_team(admin_id, player_id, team_id)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    result = @db.conn.exec("SELECT * FROM teams_players;")
    assert_equal result.ntuples, 1 # player added

    result = @db.remove_player_from_team(admin_id, player_id, team_id)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    result = @db.conn.exec("SELECT * FROM teams_players;")
    assert_equal result.ntuples, 0 # player removed
  end

  def test_create_coach
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    result = @db.create_coach!({admin_id: admin_id, name: 'Vince Lombardi' })
    result2 = @db.conn.exec("SELECT * FROM coaches;")

    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result2.ntuples, 1 # 1 coach added
  end

  def test_delete_coach
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    @db.create_coach!({admin_id: admin_id, name: 'Vince Lombardi' })
    result = @db.conn.exec("SELECT * FROM coaches;")
    assert_equal result.ntuples, 1 # 1 coach added

    result = @db.delete_coach!(admin_id, 'Vince Lombardi')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK    
    
    result = @db.conn.exec("SELECT * FROM coaches;")
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result.ntuples, 0 # coach deleted
  end

  def test_edit_coach_info
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    result = @db.create_coach!({admin_id: admin_id, name: 'Billy Bob Thornton'})
    result2 = @db.conn.exec("SELECT * FROM coaches;")
    coach_id = @db.coach_id(admin_id, 'Billy Bob Thornton')

    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result2.ntuples, 1 # 1 coach added

    options = { admin_id: admin_id, coach_id: coach_id, name: 'Jim Smith', 
                email: 'Me@Testing.com', phone: '123-456-7890' }

    result = @db.edit_coach_info(options)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    result2 = @db.conn.exec("SELECT * FROM coaches;")
    assert_equal result2.ntuples, 1 # still only 1 coach
    assert_equal result2[0]['name'], 'Jim Smith'
  end

  def test_assign_coach_to_team
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    result = @db.create_coach!({admin_id: admin_id, name: 'Billy Bob Thornton'})
    result2 = @db.conn.exec("SELECT * FROM coaches;")

    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result2.ntuples, 1 # 1 coach added

    coach_id = @db.coach_id(admin_id, 'Billy Bob Thornton')
    @db.create_sport!(admin_id, 'Baseball')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    sport_id = @db.sport_id(admin_id, 'Baseball')
    result = @db.create_league!(admin_id, sport_id, 'My Little League')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    league_id = @db.league_id(admin_id, 'My Little League')
    result = @db.create_team!(admin_id, league_id, 'Buffalo Bills')
    team_id = @db.team_id(admin_id, 'Buffalo Bills')

    result = @db.conn.exec("SELECT * FROM teams;")
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result.ntuples, 1 # team added

    result = @db.assign_coach_to_team(admin_id, coach_id, team_id)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    result = @db.conn.exec("SELECT * FROM teams_coaches;")
    assert_equal result.ntuples, 1 # coach added
  end

  def test_remove_coach_from_team
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    result = @db.create_coach!({admin_id: admin_id, name: 'Billy Bob Thornton'})
    result2 = @db.conn.exec("SELECT * FROM coaches;")

    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result2.ntuples, 1 # 1 coach added

    coach_id = @db.coach_id(admin_id, 'Billy Bob Thornton')
    @db.create_sport!(admin_id, 'Baseball')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    sport_id = @db.sport_id(admin_id, 'Baseball')
    result = @db.create_league!(admin_id, sport_id, 'My Little League')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    league_id = @db.league_id(admin_id, 'My Little League')
    result = @db.create_team!(admin_id, league_id, 'Buffalo Bills')
    team_id = @db.team_id(admin_id, 'Buffalo Bills')

    result = @db.conn.exec("SELECT * FROM teams;")
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result.ntuples, 1 # team added

    result = @db.assign_coach_to_team(admin_id, coach_id, team_id)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    result = @db.conn.exec("SELECT * FROM teams_coaches;")
    assert_equal result.ntuples, 1 # coach added

    result = @db.remove_coach_from_team(admin_id, coach_id, team_id)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    result = @db.conn.exec("SELECT * FROM teams_coaches;")
    assert_equal result.ntuples, 0 # coach removed
  end

  def test_create_game
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    result = @db.create_game!({ admin_id: admin_id, date: '2021-05-28'})
    result2 = @db.conn.exec("SELECT * FROM games;")

    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result2.ntuples, 1 # 1 game added
  end

  def test_delete_game
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    @db.create_game!({admin_id: admin_id, date: '2021-05-28'})
    result = @db.conn.exec("SELECT * FROM games;")
    assert_equal result.ntuples, 1 # 1 game added

    result = @db.delete_game!(admin_id, '2021-05-28')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK    
    
    result = @db.conn.exec("SELECT * FROM games;")
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result.ntuples, 0 # game deleted
  end

  def test_player_roster
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    admin_id = @db.admin_id('user')
    # Create 3 players
    ['Billy', 'Joe', 'Mark'].each do |name|
      @db.create_player!({ admin_id: admin_id, email: 'JoeMama@gmail.com', name: name })
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
    result = @db.player_roster(admin_id, team_id)
    # Returns rows of "Name", "Email", "Phone" as string objects
    ['Billy', 'Joe', 'Mark'].each_with_index do |name, index|
      assert_equal result[1][index][0], name
    end
  end

  def test_coach_roster
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    admin_id = @db.admin_id('user')
    # Create 3 coaches
    ['Billy', 'Joe', 'Mark'].each do |name|
      @db.create_coach!({ admin_id: admin_id, email: 'Howdy@yahoo.com', name: name })
    end
    result = @db.conn.exec("SELECT * FROM coaches;")
    assert_equal result.ntuples, 3 # 3 coaches added
    # Create a team
    @db.create_sport!(admin_id, 'Baseball')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    sport_id = @db.sport_id(admin_id, 'Baseball')
    result = @db.create_league!(admin_id, sport_id, 'My Little League')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    league_id = @db.league_id(admin_id, 'My Little League')
    result = @db.create_team!(admin_id, league_id, 'Buffalo Bills')

    team_id = @db.team_id(admin_id, 'Buffalo Bills')
    result = @db.coach_roster(admin_id, team_id)
    # Returns rows of "Name", "Email", "Phone" as string objects
    ['Billy', 'Joe', 'Mark'].each_with_index do |name, index|
      assert_equal result[1][index][0], name
    end
  end

  def test_team_schedule
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    admin_id = @db.admin_id('user')

    # Create a team
    @db.create_sport!(admin_id, 'Baseball')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    sport_id = @db.sport_id(admin_id, 'Baseball')
    result = @db.create_league!(admin_id, sport_id, 'My Little League')
    assert_instance_of PG::Result, result # PGRES_COMMAND_OK

    league_id = @db.league_id(admin_id, 'My Little League')
    @db.create_team!(admin_id, league_id, 'Buffalo Bills')
    team_id = @db.team_id(admin_id, 'Buffalo Bills')

    # Create 5 games
    @db.create_game!({ admin_id: admin_id, date: '2021-05-28', aid: team_id})
    @db.create_game!({ admin_id: admin_id, date: '2021-06-03', hid: team_id})
    @db.create_game!({ admin_id: admin_id, date: '2021-06-10', aid: team_id})
    @db.create_game!({ admin_id: admin_id, date: '2021-06-17', aid: team_id})
    @db.create_game!({ admin_id: admin_id, date: '2021-06-24', hid: team_id})
    result = @db.conn.exec("SELECT * FROM games;")

    assert_instance_of PG::Result, result # PGRES_COMMAND_OK
    assert_equal result.ntuples, 5 # 5 games added

    result = @db.team_schedule(admin_id, team_id)
    assert_instance_of Array, result # PGRES_COMMAND_OK
  end
end
