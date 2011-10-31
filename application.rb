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
	@ranges = EventRange.all(:active => 1)
	erb :signup, :locals => { :active => 'signup' }
end

### Signup Monthly View
get '/account/signup/monthly/:range' do |range|
	redirect '/' if !@user
	@month = EventRange.first(:erid => params['range'])
	@events = Event.all(:event_range => params['range'])
	@userStatus = UserEvent.all(:owner_id => @user.id)
	erb :monthly, :locals => { :active => 'signup' }
end

get '/account/signup/event/:event' do |event|
	redirect '/' if !@user
	splitArgs = params['event'].split('-')
	signup = UserEvent.first_or_create(:ueid => nil , :owner_id => splitArgs[0], :event_id => splitArgs[1], :status => 1 )
	redirect '/account/signup/monthly/'+splitArgs[2]
end

### View User Events
get '/account/view/?' do
	redirect '/' if !@user
	sql = "SELECT e.event_name, e.event_day, e.event_day_name, e.event_time, e.type, e.location, ue.position, er.month 
	FROM events e, user_events ue, event_ranges er , positions p
	WHERE e.event_range = er.erid AND er.active = 1 AND ue.event_id = e.eid  AND ue.owner_id = " + @user.id.to_s + " 
	GROUP BY ue.ueid
	ORDER BY er.erid, e.event_day"
	@events = repository(:default).adapter.select(sql)
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

### Add User

get '/admin/users/?' do
	redirect '/' if !@user.is_admin
	@users = User.all
	erb :users, :locals => { :active => 'admin' }
end

post '/admin/users/add' do
	redirect '/' if !@user.is_admin
	newUser = User.first_or_create( :id => nil, :first_name => params['first'], :last_name => params['last'], :email => params['email'], :username => params['username'], :password => params['password'], :is_admin => params['admin'] )
	redirect '/admin/users?status=added'
end

### Delete User

get '/admin/users/delete/:delete' do |delete|
	redirect '/' if !@user.is_admin
	deleteUser = User.first(:id => params['delete'])
	if deleteUser
		deleteUser.destroy
	end
	redirect '/admin/users?status=deleted'
end

### Add Event
get '/admin/add/event/r/:range/?' do |range|
	redirect '/' if !@user.is_admin
	@eventRange = EventRange.first(:erid => params['range']);
	erb :add, :locals => { :active => 'admin' }
end

post '/admin/add/event/r' do
	redirect '/' if !@user.is_admin
	new = Event.first_or_create( :eid => nil, :event_name => params['event_name'], :event_day_name => params['event_day_name'], :event_day => params['event_day'], :event_range => params['event_range_id'], :event_time => params['event_time'], :type => params['type'], :location => params['location'], :need => params['need'], :notes => params['notes'], :have => nil )
	redirect '/admin/schedule/monthly/'+params['event_range_id']
end

### Edit Event
get '/admin/edit/event/:event' do |event|
	redirect '/' if !@user.is_admin
	splitArgs = params['event'].split('-')
	@event = Event.first(:eid => splitArgs[0])
	@eventRange = EventRange.first(:erid => splitArgs[1])
	erb :admin_edit_event, :locals => { :active => 'admin' }
end

post '/admin/edit/event' do
	redirect '/' if !@user.is_admin
	updateEvent = Event.first(:eid => params['event_id'])
	if updateEvent
		updateEvent.update(:event_name => params['event_name'], :event_day => params['event_day'], :event_day_name => params['event_day_name'], :event_time => params['event_time'], :type => params['type'], :location => params['location'], :need => params['need'], :notes => params['notes'])
	end
	redirect '/admin/schedule/monthly/'+params['event_range_id']
end

### Delete Event
get '/admin/delete/event/:delete' do |event|
	redirect '/' if !@user.is_admin
	splitArgs = params['delete'].split('-')
	deleteEvent = Event.first(:eid => splitArgs[0])
	if deleteEvent
		deleteEvent.destroy
	end
	redirect '/admin/schedule/monthly/'+splitArgs[1]
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
	@Time = Time.new
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
	erb :admin_monthly, :locals => { :active => 'admin' }
end

### Event View
get '/admin/schedule/event/:event' do |event|
	redirect '/' if !@user.is_admin
	splitArgs = params['event'].split('-')
	@range = EventRange.first(:erid => splitArgs[1])
	@event = Event.first(:eid => splitArgs[0])
	type_ = @event.type
	@type = EventType.first(:etid => type_)
	@users = User.all
	erb :admin_event, :locals => { :active => 'admin' }
end

### Confirm User for Event
get '/admin/schedule/event/confirm/:info' do |info|
	redirect '/' if !@user.is_admin
	splitArgs = params['info'].split('-')
	ueid = splitArgs[0]
	event = splitArgs[1]
	range = splitArgs[2]
	position = splitArgs[3]
	updateUserEvent = UserEvent.first(:ueid => ueid)
	if updateUserEvent
		updateUserEvent.update(:position => position, :status => 2)
	end
	redirect '/admin/schedule/event/'+event+'-'+range
end

### Deny or Cancel for Event
get '/admin/schedule/event/deny/:info' do |info|
	redirect '/' if !@user.is_admin
	splitArgs = params['info'].split('-')
	ueid = splitArgs[0]
	event = splitArgs[1]
	range = splitArgs[2]
	updateUserEvent = UserEvent.first(:ueid => ueid)
	if updateUserEvent
		updateUserEvent.update(:status => 3)
	end
	redirect '/admin/schedule/event/'+event+'-'+range
end

### Add Positions
get '/admin/positions' do
	redirect '/' if !@user.is_admin
	@position = Position.all
	erb :positions, :locals => { :active => 'admin' }
end

post '/admin/positions/add' do
	redirect '/' if !@user.is_admin
	newPosition = Position.first_or_create(:pid => nil, :name => params['name'])
	redirect '/admin/positions?status=added'
end

### Delete Position
get '/admin/position/delete/:position' do |position|
	redirect '/' if !@user.is_admin
	deletePosition = Position.first(:pid => params['position'])
	if deletePosition
		deletePosition.destroy
	end
	redirect '/admin/positions?status=deleted'
end