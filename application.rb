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
	erb :account, :locals => {:name => params[:username]}
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

###########################
########## Admin ##########

### Admin Add Event
get '/admin/add' do
	redirect '/' if !@user
	erb :add
end
