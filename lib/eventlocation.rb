# Event Location Table Structure
require 'dm-core'

class EventLocation
	include DataMapper::Resource
	
	property :elid, 	Serial
	property :name,		String
	
	has n, :Event
end
