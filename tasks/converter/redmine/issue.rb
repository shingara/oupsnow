class Redmine::Issue
  include DataMapper::Resource
  
  property :id,     Serial
  property :subject,  String
  property :description, Text
  property :category_id, Integer
  property :status_id, Integer
  property :assigned_to_id, Integer
  property :priority_id, Integer
  property :author_id, Integer
  property :created_on, DateTime
  property :tracker_id, Integer
  property :fixed_version_id, Integer


  belongs_to :assigned_to, :class_name => "User", :child_key => [:assigned_to_id]
  belongs_to :version, :class_name => "Version", :child_key => [:fixed_version_id]
  belongs_to :created_by, :class_name => "User", :child_key => [:author_id]
  belongs_to :project
  belongs_to :status
  belongs_to :priority, :class_name => "Enumeration", :child_key => [:priority_id]
  belongs_to :category, :class_name => "Category", :child_key => [:category_id]
  belongs_to :tracker, :class_name => "Tracker", :child_key => [:tracker_id]

  def self.repository_name
    :redmine
  end

  def self.default_storage_name
    'issue'
  end

end
