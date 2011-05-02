require "sinatra"

### Home
get '/' do
	erb :main
end

### Login Attempt
post '/account' do
	erb :account, :locals => {:name => params[:username]}
end

########## Admin ##########

### Admin Add Event
get '/admin/add' do
	erb :add
end