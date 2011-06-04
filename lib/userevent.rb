# User Event Table Structure
require 'dm-core'

class UserEvent
	include DataMapper::Resource
	
	property :ueid,		Serial, :required => true
	property :owner_id,	Integer, :required => true
	property :event_id,	Integer, :required => true
	property :status,	Integer, :default => 0
	property :switch,	Integer, :default => 0
	property :position, Integer, :default => 0
	
	belongs_to :Event
	belongs_to :User
	belongs_to :Position
end
