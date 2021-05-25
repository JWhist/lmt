#main app
require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader' if development?
require 'tilt/erubis'
require 'sinatra/contrib'
require 'bcrypt'
require 'date'
require_relative './lib/admin'
require_relative './lib/coach'
require_relative './lib/dbcontroller'
require_relative './lib/game'
require_relative './lib/league'
require_relative './lib/player'
require_relative './lib/sport'
require_relative './lib/team'

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
    else
      "Username has already been taken.  Please try another."
    end
  end

  def require_signed_in_admin
    if !session[:id]
      session[:message] = "Please sign in."
      redirect '/login'
    end
  end

  def reset_session
    session[:id] = nil
  end
end

get '/' do
  redirect '/login'
end

# Landing page --> Sign in
get '/login' do
  erb :login
end

# Log in
post '/login' do  
  username = params[:username]
  password = params[:password]
  
  if @db.user_is_verified?(username, password)
    session[:message] = "Welcome Back, #{username}!"
    session[:id] = @db.admin_id(username)
    
    redirect "/admin/#{session[:id]}"
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
  
  erb :new
end

# "HOME" page
get '/admin/:id' do
  require_signed_in_admin
end

# Create an admin
post '/admin/new' do
  username = params[:username]
  password = params[:password]

  if @db.validates_credentials?(username, password)
    password = BCrypt::Password.create(password)
    @db.create_admin!(username, password)
    session[:id] = @db.admin_id(username)
    session[:message] = "New user \"#{username}\" created."
    
    redirect "/admin/#{session[:id]}"
  else
    session[:message] = clarify_signup_error(username, password)
    erb :new
  end 
end

# Delete an Admin
post '/admin/:id/delete' do
  require_signed_in_admin
end

# Sport routes
get '/sport/new' do
  requre_signed_in_admin
end
get '/sport/:id' do
  requre_signed_in_admin
end
post '/sport/new' do
  requre_signed_in_admin
end
post '/sport/:id/delete' do
  requre_signed_in_admin
end

# League routes
get '/league/new' do
  requre_signed_in_admin
end
get '/league/:id' do
  requre_signed_in_admin
end
post '/league/new' do
  requre_signed_in_admin
end
post '/league/:id/delete' do
  requre_signed_in_admin
end

# Team routes
get '/team/new' do
  requre_signed_in_admin
end
get '/team/:id' do
  requre_signed_in_admin
end
post '/team/new' do
  requre_signed_in_admin
end
post '/team/:id/delete' do
  requre_signed_in_admin
end

# Coach routes
get '/coach/new' do
  requre_signed_in_admin
end
get '/coach/:id' do
  requre_signed_in_admin
end
post '/coach/new' do
  requre_signed_in_admin
end
post '/coach/:id/delete' do
  requre_signed_in_admin
end

# Player routes
get '/player/new' do
  requre_signed_in_admin
end
get '/player/:id' do
  requre_signed_in_admin
end
post '/player/new' do
  requre_signed_in_admin
end
post '/player/:id/delete' do
  requre_signed_in_admin
end

# Game routes
get '/game/new' do
  requre_signed_in_admin
end
get '/game/:id' do
  requre_signed_in_admin
end
post '/game/new' do
  requre_signed_in_admin
end
post '/game/:id/delete' do
  requre_signed_in_admin
end
