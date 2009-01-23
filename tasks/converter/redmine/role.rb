class Redmine::Role
  include DataMapper::Resource
  
  property :id,     Serial
  property :name,  String
  property :permissions, Text 

  def self.repository_name
    :redmine
  end

  def self.default_storage_name
    'role'
  end

  def can_edit_project
    permissions =~ /:edit_project/
  end

end
