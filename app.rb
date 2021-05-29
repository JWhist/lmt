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

  admin_id = session[:admin_id]
  sport_name = params[:sport]
  @sports = @db.sports(admin_id)

  if sport_name
    sport_id = @db.sport_id(admin_id, sport_name)
    @leagues = @db.leagues(admin_id, sport_id)
  end

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
    session[:message] = "New user \"#{username}\" created."
    
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

  redirect '/admin'
end

post '/sport/delete' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  sport = params[:sport]
  @db.delete_sport!(admin_id, sport)
  params[:sport] = nil

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

  redirect '/admin'
end

post '/league/delete' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  league = params[:league]
  @db.delete_league!(admin_id, league)

  redirect '/admin'
end

# Team routes
get '/team/new' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  @sports = @db.sports(admin_id)

  erb :newteam
end
get '/team/schedule' do
  require_signed_in_admin
  admin_id = session[:admin_id]

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

  redirect '/admin'
end

post '/team/delete' do
  require_signed_in_admin

  admin_id = session[:admin_id]
  team = params[:team]
  @db.delete_team!(admin_id, team)

  redirect '/admin'
end

# Coach routes
get '/coach/new' do
  require_signed_in_admin
end
get '/coach' do
  require_signed_in_admin
end
post '/coach/new' do
  require_signed_in_admin
end
post '/coach/delete' do
  require_signed_in_admin
end

# Player routes
get '/player/new' do
  require_signed_in_admin
end
get '/player' do
  require_signed_in_admin
end
post '/player/new' do
  require_signed_in_admin
end
post '/player/delete' do
  require_signed_in_admin
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
  puts options
  @db.create_game!(options)

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

  p date, team, team_id

  @db.delete_game!(admin_id, date, team_id)

  redirect '/admin'
end
