# User Table Structure
require 'dm-core'
require 'dm-types/bcrypt_hash'

class User
	include DataMapper::Resource
	
	property :id,			Serial
	property :first_name,	String,	:required => true
	property :last_name,	String,	:required => true
	property :email,		String, :required => true
	property :username,		String, :required => true, :unique_index => true
	property :password,		BCryptHash, :required => true
	property :is_admin,		Boolean, :default => false

end
