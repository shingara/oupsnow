module Redmine
  class User
  include DataMapper::Resource

  property :id,     Serial
  property :login,  String
  property :mail,  String
  property :firstname, String
  property :lastname, String
  property :admin, Boolean

  def self.repository_name
    :redmine
  end

  def self.default_storage_name
    'user'
  end

  end
end
