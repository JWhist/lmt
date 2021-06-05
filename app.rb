#main app
require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader' if development?
require 'tilt/erubis'
require 'sinatra/contrib'
require 'bcrypt'
require 'date'
require_relative './lib/dbcontroller'


configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(64)
  set :erb, :escape_html => true
end

before do 
  @db = DBController.new
end

after do
  @db.disconnect
end

helpers do
  def format_date(date)
    return nil if date.nil?

    year, month, day = date.split('-')
    "#{month}/#{day}/#{year}"
  end

  # TODO: ADD PASSWORD CRITERIA
  def clarify_signup_error(username, password)
    if username.match?(/\s/) || password.match?(/\s/)
      "Username/password cannot contain spaces."
    elsif [username, password].any? { |cred| cred.strip == "" || cred.nil? }
      "Please enter a username and password."
    # elsif !meets_password_criteria(password) "Password must xxx"
    else
      "Username has already been taken.  Please try another."
    end
  end

  def require_signed_in_admin
    if !session[:admin_id]
      session[:message] = "Please sign in."
      redirect '/login'
    end
  end

  def reset_session
    session[:admin_id] = nil
  end
end

get '/' do
  redirect '/login'
end

# Landing page --> Sign in
get '/login' do
  @title = 'LMT - Login Page'
  session['SameSite'] = 'Strict'

  erb :login
end

# Log in
post '/login' do  
  username = params[:username]
  password = params[:password]
  
  if @db.user_is_verified?(username, password)
    session[:message] = "Welcome Back, #{username}!"
    session[:username] = username
    session[:admin_id] = @db.admin_id(username)
    
    redirect "/admin"
  else
    session[:message] = "Invalid Username/Password."
    erb :login
  end
end

# Log out
get '/logout' do
  session[:message] = "Goodbye!"
  reset_session

  redirect '/login'
end

# Admin page ---> To create an admin
get '/admin/new' do
  @title = 'LMT - Create New Admin'
  erb :new
end

# "HOME" page
get '/admin' do
  require_signed_in_admin
  
  @username = session[:username]
  admin_id = session[:admin_id]
  sport_name = params[:sport]
  @sports = @db.sports(admin_id)

  # if sport_name
  #   sport_id = @db.sport_id(admin_id, sport_name)
  #   @leagues = @db.leagues(admin_id, sport_id)
  # end

  @title = 'LMT - Admin Home Page'

  erb :admin
end

# Create an admin
post '/admin/new' do
  username = params[:username].strip
  password = params[:password].strip

  if @db.validates_credentials?(username, password)
    password = BCrypt::Password.create(password)
    @db.create_admin!(username, password)
    session[:admin_id] = @db.admin_id(username)
    session[:message] = "New user \"#{username}\" has been created."
    
    redirect "/admin"
  else
    session[:message] = clarify_signup_error(username, password)
    erb :new
  end 
end

# Delete an Admin
post '/admin/delete' do
  require_signed_in_admin

  id = session[:admin_id]
  @db.delete_admin!(id)
  session[:message] = "Admin has been deleted."
  reset_session

  redirect '/login'
end

# Sport routes
get '/sport/new' do
  require_signed_in_admin

  erb :newsport
end

get '/sport' do
  require_signed_in_admin
end

post '/sport/new' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  name = params[:name]
  @db.create_sport!(admin_id, name)

  session[:message] = 'New sport has been created'
  redirect '/admin'
end

post '/sport/delete' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  sport = params[:sport]
  
  @db.delete_sport!(admin_id, sport)
  
  session[:message] = 'Sport deleted'
  redirect '/admin'
end

# League routes
get '/league/new' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  @sports = @db.sports(admin_id)

  erb :newleague
end

post '/leagues' do
  content_type :json
  require_signed_in_admin

  sport = params[:sport]
  admin_id = session[:admin_id]
  sport_id = @db.sport_id(admin_id, sport)

  @db.leagues(admin_id, sport_id).to_json
end

post '/league/new' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  sport = params[:sport]
  sport_id = @db.sport_id(admin_id, sport)
  league_name = params[:league_name]
  @db.create_league!(admin_id, sport_id, league_name)

  session[:message] = 'New league has been created'
  redirect '/admin'
end

post '/league/delete' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  league = params[:league]

  @db.delete_league!(admin_id, league)

  session[:message] = 'League deleted'
  redirect '/admin'
end

# Team routes
get '/team/new' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  @sports = @db.sports(admin_id)

  erb :newteam
end

get '/league/schedule' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  league = params[:league]
  league_id = @db.league_id(admin_id, league)

  @schedule = @db.league_schedule(admin_id, league_id)

  erb :schedule
end

post '/teams' do
  content_type :json
  require_signed_in_admin

  league = params[:league]
  admin_id = session[:admin_id]
  league_id = @db.league_id(admin_id, league)

  @db.teams(admin_id, league_id).to_json
end

post '/team/new' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  league = params[:league]
  league_id = @db.league_id(admin_id, league)
  team_name = params[:team_name]

  @db.create_team!(admin_id, league_id, team_name)

  session[:message] = 'New team has been created'
  redirect '/admin'
end

post '/team/delete' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  team = params[:team]

  @db.delete_team!(admin_id, team)

  session[:message] = 'Team deleted'
  redirect '/admin'
end

get '/admin/roster' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  sql = "SELECT name, email, phone FROM players WHERE admin_id = $1;"
  @players = @db.conn.exec_params(sql, [admin_id]).values
  sql = "SELECT name, email, phone FROM coaches WHERE admin_id = $1;"
  @coaches = @db.conn.exec_params(sql, [admin_id]).values

  erb :roster
end

get '/team/roster' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  @team_name = params[:team]
  team_id = @db.team_id(admin_id, @team_name)

  @players = @db.player_roster(admin_id, team_id)
  @coaches = @db.coach_roster(admin_id, team_id)

  erb :roster
end

# Coach routes
get '/coach/new' do
  require_signed_in_admin

  erb :newcoach
end

post '/coaches' do
  content_type :json
  require_signed_in_admin

  admin_id = session[:admin_id]

  @db.coaches(admin_id).to_json
end

post '/coach/new' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  coach_name = params[:name]
  coach_email = params[:email]
  coach_phone = params[:phone]
  options = { admin_id: admin_id, name: coach_name, 
              email: coach_email, phone: coach_phone }

  @db.create_coach!(options)
  @session[:message] = "Coach has been created"
  redirect '/admin'
end

post '/coach/delete' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  coach_id = params[:coach_id]

  @db.delete_coach!(admin_id, coach_id)
end

post '/coach/assign' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  team_id = @db.team_id(admin_id, params[:team])
  coach_id = params[:coach_id]
  p admin_id, team_id, coach_id
  
  @db.assign_coach_to_team(admin_id, coach_id, team_id)
  session[:message] = 'Coach assigned to team'

  redirect '/admin'
end

post '/coach/remove' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  team_id = @db.team_id(admin_id, params[:team])
  coach_id = params[:coach_id]
  p admin_id, team_id, coach_id
  
  @db.remove_coach_from_team(admin_id, coach_id, team_id)
  session[:message] = 'Coach removed from team'

  redirect '/admin'
end

# Player routes
get '/player/new' do
  require_signed_in_admin

  erb :newplayer
end

post '/player/assign' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  team_id = @db.team_id(admin_id, params[:team])
  player_id = params[:player_id]
  p admin_id, team_id, player_id
  
  @db.assign_player_to_team(admin_id, player_id, team_id)
  session[:message] = 'Player assigned to team'

  redirect '/admin'
end

post '/player/remove' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  team_id = @db.team_id(admin_id, params[:team])
  player_id = params[:player_id]
  p admin_id, team_id, player_id
  
  @db.remove_player_from_team(admin_id, player_id, team_id)
  session[:message] = 'Player removed from team'

  redirect '/admin'
end

post '/players' do
  content_type :json
  require_signed_in_admin

  admin_id = session[:admin_id]

  @db.players(admin_id).to_json
end

post '/player/new' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  player_name = params[:name]
  player_email = params[:email]
  player_phone = params[:phone]
  options = { admin_id: admin_id, name: player_name, 
              email: player_email, phone: player_phone }

  @db.create_player!(options)

  @session[:message] = "Player has been created"
  redirect '/admin'
end

post '/player/delete' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  player_id = params[:player_id]

  @db.delete_player!(admin_id, player_id)
end

# Game routes
get '/game/new' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  @sports = @db.sports(admin_id)

  erb :newgame
end

post '/game/new' do
  require_signed_in_admin
  admin_id = session[:admin_id]
  date = format_date(params[:date])
  venue = params[:venue]
  hometeam = params[:hometeam]
  awayteam = params[:awayteam]
  hid = @db.team_id(admin_id, hometeam)
  aid = @db.team_id(admin_id, awayteam)

  options = { admin_id: admin_id, date: date, venue: venue, hid: hid, aid: aid }
  @db.create_game!(options)

  @session[:message] = "Game has been created"
  redirect '/admin'
end

post '/games' do
  content_type :json
  require_signed_in_admin

  team = params[:team]
  admin_id = session[:admin_id]
  team_id = @db.team_id(admin_id, team)

  @db.team_schedule(admin_id, team_id).to_json
end

post '/game/delete' do
  require_signed_in_admin
  admin_id = session[:admin_id]

  date = params[:date]
  team = params[:team]

  team_id = @db.team_id(admin_id, team)


  @db.delete_game!(admin_id, date, team_id)

  session[:message] = 'Game deleted'
  
  @sports = @db.sports(admin_id)
  erb :admin
end

post '/password/new' do
  require_signed_in_admin

  username = session[:username]
  newpassword = BCrypt::Password.create(params[:password])

  @db.change_admin_password(username, newpassword)

  session[:message] = 'Admin password has been changed'
  
  redirect '/admin'
end