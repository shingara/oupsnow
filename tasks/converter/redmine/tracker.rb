class Redmine::Tracker
  include DataMapper::Resource
  property :id, Serial
  property :name, String

  def self.repository_name
    :redmine
  end

  def self.default_storage_name
    'tracker'
  end
end
