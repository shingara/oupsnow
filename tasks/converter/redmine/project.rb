class Redmine::Project
  include DataMapper::Resource
  
  property :id,     Serial
  property :name,  String
  property :description,  Text

  def self.repository_name
    :redmine
  end

  def self.default_storage_name
    'project'
  end

end
