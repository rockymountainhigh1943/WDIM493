# User Event Table Structure
require 'dm-core'
require 'dm-types/bcrypt_hash'

class UserEvent
	include DataMapper::Resource
	
	property :id,		Serial
	property :event_id,	Integer
	property :owner_id,	Integer
	
end
