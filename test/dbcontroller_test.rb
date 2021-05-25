require'sinatra'
set :environment, :test
require 'minitest/autorun'
require_relative '../lib/dbcontroller'
require 'minitest/reporters'
MiniTest::Reporters.use!

class DBControllerTest < MiniTest::Test
  def setup
    @db = DBController.new
  end

  def teardown
    begin
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
end
