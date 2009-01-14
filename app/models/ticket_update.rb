class TicketUpdate
  include DataMapper::Resource
  
  property :id, Serial
  property :properties_update, Yaml, :default => []
  property :description, Text
  property :created_at, DateTime

  belongs_to :created_by, :class_name => "User", :child_key => [:member_create_id]
  belongs_to :ticket

end
