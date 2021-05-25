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
      @db.conn.exec("DELETE FROM leagues")
      @db.conn.exec("DELETE FROM sports")
      @db.conn.exec("DELETE FROM admins")
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

    assert_equal result.result_status, 1 # PGRES_COMMAND_OK
  end

  def test_delete_admin
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)

    assert_equal result.result_status, 1 # PGRES_COMMAND_OK

    id = @db.admin_id('user')
    result = @db.delete_admin!(id)
    result2 = @db.conn.exec("SELECT * FROM admins")

    assert_equal result.result_status, 1 # PGRES_COMMAND_OK
    assert_equal result2.ntuples, 0 # No admins left in table
  end

  def test_change_admin_password
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)

    assert_equal result.result_status, 1 # PGRES_COMMAND_OK

    newpassword = BCrypt::Password.create('newpassword')
    result = @db.change_admin_password('user', newpassword)
    result2 = @db.conn.exec("SELECT * FROM admins")

    assert_equal result.result_status, 1 # PGRES_COMMAND_OK
    assert_equal result.ntuples, 0
    assert_equal result2.ntuples, 1 # still only 1 user
  end

  def test_create_sport
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)

    assert_equal result.result_status, 1 # PGRES_COMMAND_OK

    id = @db.admin_id('user')
    result = @db.create_sport!(id, 'Baseball')
    result2 = @db.conn.exec("SELECT * FROM sports")
    p result2
    assert_equal result.result_status, 1 # PGRES_COMMAND_OK
    assert_equal result2.ntuples, 1 # 1 sport added
  end

  def test_create_league
    password = BCrypt::Password.create('password')
    result = @db.create_admin!('user', password)

    assert_equal result.result_status, 1 # PGRES_COMMAND_OK

    admin_id = @db.admin_id('user')
    @db.create_sport!(admin_id, 'Baseball')

    assert_equal result.result_status, 1 # PGRES_COMMAND_OK

    sport_id = @db.sport_id(admin_id, 'Baseball')
    result = @db.create_league!(admin_id, sport_id, 'Baseball')
    result2 = @db.conn.exec("SELECT * FROM leagues")
    p result2
    assert_equal result.result_status, 1 # PGRES_COMMAND_OK
    assert_equal result2.ntuples, 1 # 1 league added
  end
end
