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
		else
		redirect '/'
	end
end

### Dashboard
get '/account/?' do
	redirect '/' if !@user
	erb :account, :locals => { :name => @user.first_name, :active => nil }
end

### Signup
get '/account/signup/?' do
	redirect '/' if !@user
	erb :signup, :locals => { :active => 'signup' }
end

### View User Events
get '/account/view/?' do
	redirect '/' if !@user
	erb :view, :locals => { :active => 'view' }
end

### View All Events
get '/account/view/all/?' do
	redirect '/' if !@user
	erb :viewall, :locals => { :active => 'all' }
end

### Request Switch
get '/account/switch/?' do
	redirect '/' if !@user
	erb :switch, :locals => { :active => 'switch' }
end

### Account Settings
get '/account/settings/?' do
	redirect '/' if !@user
	erb :settings, :locals => { :active => 'settings' }
end

post '/account/settings' do
	redirect '/' if !@user
	@user.update( :first_name => params[:first], :last_name => params[:last], :email => params['email'] )
	redirect '/account/settings?status=changed' 
end

get '/account/passchange/?' do
	redirect '/' if !@user
	erb :passchange, :locals => { :active => 'settings' }
end

post '/account/passchange' do
	redirect '/' if !@user
		if params[:user] == @user.username and params[:newPass] == params[:againPass]
			@user.update( :password => params[:newPass] )
			redirect '/account/passchange?status=changed'
		else
			redirect '/account/passchange?status=failed'
		end
end

### Logout
get '/logout/?' do
	session.clear
	redirect '/'
end

###########################
########## Admin ##########

get '/admin/?' do
	redirect '/' if !@user.is_admin
	erb :admin, :locals => { :active => 'admin' }
end

### Add Event
get '/admin/add/event/r/:range/?' do |range|
	redirect '/' if !@user.is_admin
	@eventRange = EventRange.first(:erid => params['range']);
	erb :add, :locals => { :active => 'admin' }
end

post '/admin/add/event/r' do
	redirect '/' if !@user.is_admin
	new = Event.first_or_create( :eid => nil, :event_name => params['event_name'], :event_day_name => params['event_day_name'], :event_day => params['event_day'], :event_range => params['event_range_id'], :event_time => params['event_time'], :type => params['type'], :location => params['location'], :need => params['need'], :notes => params['notes'] )
	redirect '/admin/schedule/monthly/'+params['event_range_id']
end

### Schedule
get '/admin/schedule/?' do
	redirect '/' if !@user.is_admin
	@ranges = EventRange.all(:active => 1)
	erb :admin_schedule, :locals => { :active => 'admin' }
end

### Archives
get '/admin/archives/?' do
	redirect '/' if !@user.is_admin
	@archives = EventRange.all(:active => 0)
	erb :admin_archive, :locals => { :active => 'admin' }
end

### Add Range
get '/admin/add/range/?' do
	redirect '/' if !@user.is_admin
	erb :admin_add_range, :locals => { :active => 'admin' }
end

post '/admin/add/range' do
	redirect '/' if !@user.is_admin
	newRange = EventRange.first_or_create( :erid => nil, :month => params['month'], :year => params['year'], :per_user => params['perUser'], :active => '1' )
	redirect '/admin/schedule'
end

### Edit Range/
get '/admin/edit/range/:range' do |range|
	redirect '/' if !@user.is_admin
	@whichRange = EventRange.first(:erid => params['range'])
	erb :admin_edit_range, :locals => { :active => 'admin' }
end

post '/admin/edit/range' do
	redirect '/' if !@user.is_admin
	updateRange = EventRange.first(:erid => params['erid'])
	if updateRange
		updateRange.update( :month => params['month'], :year => params['year'], :per_user => params['perUser'] )
	end
	redirect '/admin/schedule'
end

### Delete Range
get '/admin/delete/range/:range' do |range|
	redirect '/' if !@user.is_admin
	deleteRange = EventRange.first(:erid => params['range'])
	if deleteRange
		deleteRange.destroy
	end
	redirect '/admin/schedule'
end

### Archive Range 
get '/admin/archive/range/:range' do |range|
	redirect '/' if !@user.is_admin
	archiveRange = EventRange.first(:erid => params['range'])
	if archiveRange
		archiveRange.update(:active => 0)
	end
	redirect '/admin/schedule'
end

### Activate Range 
get '/admin/activate/range/:range' do |range|
	redirect '/' if !@user.is_admin
	activateRange = EventRange.first(:erid => params['range'])
	if activateRange
		activateRange.update(:active => 1)
	end
	redirect '/admin/schedule'
end

### Monthly View
get '/admin/schedule/monthly/:range' do |range|
	redirect '/' if !@user.is_admin
	@month = EventRange.first(:erid => params['range'])
	@events = Event.all(:event_range => params['range'])
	#@types = EventType.first(:etid => @events.type)
	#@locations = EventLocation.first(:elid => @events.location)
	erb :admin_monthly, :locals => { :active => 'admin' }
end
