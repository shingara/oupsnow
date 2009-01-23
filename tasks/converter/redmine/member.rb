class Redmine::Member
  include DataMapper::Resource
  
  property :id,     Serial
  property :user_id,  Integer
  property :project_id, Integer
  property :role_id, Integer

  belongs_to :user
  belongs_to :project
  belongs_to :role

  def self.repository_name
    :redmine
  end

  def self.default_storage_name
    'member'
  end

end
