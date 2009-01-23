class Redmine::Enumeration
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :opt, String

  def self.repository_name
    :redmine
  end

  def self.default_storage_name
    'enumeration'
  end
end
