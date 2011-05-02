require "sinatra"

helpers do
    include Rack::Utils
    alias_method :h, :escape_html
end

### Home
get '/' do
	'<!DOCTYPE html>
	<html>
	<head>
	  <title>Test</title>
	</head>
	<body>
	  <h1>Hello World</h1>
	  <p>Some text would go here I suspect.</p>
	</body>
	</html>'
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