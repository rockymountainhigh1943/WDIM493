require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require File.join(File.dirname(__FILE__), 'environment')

enable :sessions

helpers do
    include Rack::Utils
    alias_method :h, :escape_html
end

before do
	@user = User.get(session[:id])
end

### Home
get '/' do
	erb :main
end

### Dashboard
post '/account' do
	redirect '/' if !@user
	erb :account, :locals => {:name => params[:username]}
end

### View User Events
get '/account/view' do
	erb :view
end

### View All Events
get '/account/view/all' do
	erb :viewall
end

### Request Switch
get '/account/switch' do
	erb :switch
end

### Account Settings
get '/account/settings' do
	erb :settings
end

###########################
########## Admin ##########

### Admin Add Event
get '/admin/add' do
	erb :add
end
