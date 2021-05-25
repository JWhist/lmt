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
    result = @db.delete_admin(id)
    tablesize = @db.conn.exec("SELECT * FROM admins")

    assert_equal result.result_status, 1 # PGRES_COMMAND_OK
    assert_equal tablesize.ntuples, 0 # No admins left in table
  end
end
