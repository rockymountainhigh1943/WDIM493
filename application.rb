require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'data_mapper'
require File.join(File.dirname(__FILE__), 'environment')

enable :sessions

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
end

error do
  e = request.env['sinatra.error']
  Kernel.puts e.backtrace.join("\n")
  'Application error'
end

helpers do
    include Rack::Utils
    alias_method :h, :escape_html
end

before do
	@user = User.get(session[:user_id])
end

### Home
get '/' do
	erb :main
end

post '/' do
	user = User.first :username => params[:username]
  	if user and user.password == params[:userpass]
		@user = user
		session.clear
		session[:user_id] = @user.id
		redirect '/'
	end
end

### Dashboard
get '/account' do
	redirect '/' if !@user
	erb :account, :locals => { :name => @user.first_name }
end

### View User Events
get '/account/view' do
	redirect '/' if !@user
	erb :view
end

### View All Events
get '/account/view/all' do
	redirect '/' if !@user
	erb :viewall
end

### Request Switch
get '/account/switch' do
	redirect '/' if !@user
	erb :switch
end

### Account Settings
get '/account/settings' do
	redirect '/' if !@user
	erb :settings
end

### Logout
get '/logout' do
	session.clear
	redirect '/'
end

###########################
########## Admin ##########

### Admin Add Event
get '/admin/add' do
	redirect '/' if !@user
	erb :add
end
