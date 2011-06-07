# Master Event Table Structure
require 'dm-core'

class Event
	include DataMapper::Resource
	
	property :eid,			Serial
	property :event_name,	String, :required => true
	property :event_day,	Integer, :required => true
	property :event_day_name,	String, :required => true
	property :event_range,	Integer, :required => true
	property :event_time,	String, :required => true
	property :type,			Integer, :required => true
	property :location,		Integer, :required => true
	property :need,			Integer, :required => true
	property :have,			Integer
	property :notes,		Text
end
