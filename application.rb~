require "sinatra"

helpers do
    include Rack::Utils
    alias_method :h, :escape_html
end

get '/' do
	erb :main
end

post '/account' do
	erb :account, :locals => {:name => params[:username]}
end

########## Admin ##########

### Admin Add Event
get '/admin/add' do
	erb :add
end