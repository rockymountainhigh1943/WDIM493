# Event Type Table Structure
require 'dm-core'

class EventType
	include DataMapper::Resource
	
	property :etid, 	Serial
	property :name,		String
end
