class Redmine::Version
  include DataMapper::Resource

  property :id, Serial
  property :project_id, Integer
  property :name, String
  property :description, String
  property :effective_date, Date

  def self.repository_name
    :redmine
  end

  def self.default_storage_name
    'version'
  end
end
