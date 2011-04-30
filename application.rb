require "sinatra"

### Home
get '/' do
	erb :main
end

### Login Attempt
post '/' do
	erb :main
end

########## Admin ##########

### Admin Add Event
get '/admin/add' do
	erb :add
end