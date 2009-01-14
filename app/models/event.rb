class Event
  include DataMapper::Resource
  
  property :id, Serial
  property :eventable_class, String, :nullable => false
  property :eventable_id, Integer, :nullable => false
  property :event_type, Enum[:created, :updated], :nullable => false
  property :user_id, Integer, :nullable => false
  property :project_id, Integer, :nullable => false
  
  belongs_to :user
  belongs_to :project

end
