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
	redirect '/account' if @user
	erb :main, :locals => { :active => nil }
end

post '/' do
	user = User.first :username => params[:username]
  	if user and user.password == params[:userpass]
		@user = user
		session.clear
		session[:user_id] = @user.id
		redirect '/account'
	end
end

### Dashboard
get '/account' do
	redirect '/' if !@user
	erb :account, :locals => { :name => @user.first_name, :active => nil }
end

### View User Events
get '/account/view' do
	redirect '/' if !@user
	erb :view, :locals => { :name => @user.first_name, :active => 'view' }
end

### View All Events
get '/account/view/all' do
	redirect '/' if !@user
	erb :viewall, :locals => { :name => @user.first_name, :active => 'all' }
end

### Request Switch
get '/account/switch' do
	redirect '/' if !@user
	erb :switch, :locals => { :name => @user.first_name, :active => 'switch' }
end

### Account Settings
get '/account/settings' do
	redirect '/' if !@user
	erb :settings, :locals => { :name => @user.first_name, :active => 'settings' }
end

post '/account/settings' do
	redirect '/' if !@user
	@user.update( :first_name => params[:first], :last_name => params[:last], :email => params['email'] )
	redirect '/account/settings' 
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
	redirect '/' if !@user.is_admin
	erb :add, :locals => { :name => @user.first_name, :active => nil }
end

post '/admin/add' do
	redirect '/' if !@user.is_admin
	new = Event.first_or_create( :eid => nil, :event_name => 'event_name', :event_month => '5', :event_day => '23', :event_year => '2011', :event_time => 'event_time', :type => 'type', :location => 'location', :needed => '12' )
	redirect '/admin/add'
end
