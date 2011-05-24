# Master Event Table Structure
require 'dm-core'
require 'dm-types/bcrypt_hash'

class Event
	include DataMapper::Resource
	
	property :eid,			Serial
	property :event_name,	String, :required => true
	property :event_month,	Integer, :required => true
	property :event_day,	Integer, :required => true
	property :event_year,	Integer, :required => true
	property :event_time,	String, :required => true
	property :type,			String, :required => true
	property :location,		String, :required => true
	property :needed,		Integer, :required => true
	property :have,			Integer
	property :notes,		Text

end
