require 'sinatra'

require File.join(File.dirname(__FILE__), 'coordinator')

run Sinatra::Application
