class Redmine::Status
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :is_closed, Boolean

  def self.repository_name
    :redmine
  end

  def self.default_storage_name
    'issue_status'
  end
end
