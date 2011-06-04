# Position Table Structure
require 'dm-core'

class Position
	include DataMapper::Resource
	
	property :pid, 		Serial
	property :name,		Integer
	
	has n, :UserEvent
end
