class TicketUpdate
  include DataMapper::Resource
  
  property :id, Serial
  property :properties_update, Yaml, :default => []
  property :description, Text
  property :created_at, DateTime

  belongs_to :created_by, :class_name => "User", :child_key => [:member_create_id]
  belongs_to :ticket

  after :create, :write_event

  def write_event
    Event.create(:eventable_class => self.class,
                 :eventable_id => id,
                 :user_id => member_create_id,
                 :event_type => :updated)
  end


end
