require "sinatra"

helpers do
    include Rack::Utils
    alias_method :h, :escape_html
end

### Home
get '/' do
	erb :main
end

### Dashboard
post '/account' do
	erb :account, :locals => {:name => params[:username]}
end

### View User Events
get '/account/view/' do
	erb :view
end

### Request Switch
get '/account/switch/' do
	erb :switch
end

########## Admin ##########

### Admin Add Event
get '/admin/add' do
	erb :add
end
