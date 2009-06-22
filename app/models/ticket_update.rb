class TicketUpdate
  include DataMapper::Resource
  include DataMapper::Constraints
  
  property :id, Serial
  property :properties_update, Yaml, :default => []
  property :description, Text
  property :created_at, DateTime
  property :member_create_id, Integer, :nullable => false

  belongs_to :created_by, :model => "User", :child_key => [:member_create_id]
  belongs_to :ticket

  def write_event
    Event.create(:eventable_class => self.class,
                 :eventable_id => self.id,
                 :user_id => self.member_create_id,
                 :event_type => :updated,
                 :project_id => self.ticket.project_id)
  end

end
