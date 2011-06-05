# Event Range Table Structure
require 'dm-core'

class EventRange
	include DataMapper::Resource
	
	property :erid, 	Serial
	property :month,	Integer
	property :year,		Integer
	property :per_user,	Integer
	property :active,	Integer
end
