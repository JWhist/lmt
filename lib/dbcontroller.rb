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

  def create_admin!(username, password)
    sql = <<~SQL
    INSERT INTO admins (username, password) VALUES
    ($1, $2);
    SQL
    @conn.exec_params(sql, [username, password])
  end

  def delete_admin(id)
    sql = "DELETE FROM admins WHERE id = $1;"
    @conn.exec_params(sql, [id])
  end

  def admin_id(username)
    sql = <<~SQL
    SELECT id FROM admins WHERE username = $1;
    SQL
    result = @conn.exec_params(sql, [username])
    result[0]["id"].to_i
  end

  def change_admin_password(username, password)
    sql = <<~SQL
    UPDATE admins (
    SET password = $2
    WHERE username = $1);
    SQL
    @conn.exec_params(sql, [username, password])
  end
end