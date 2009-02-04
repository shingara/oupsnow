class Event
  include DataMapper::Resource
  include DataMapper::Constraints
  
  property :id, Serial
  property :eventable_class, String, :nullable => false
  property :eventable_id, Integer, :nullable => false
  property :event_type, Enum[:created, :updated], :nullable => false
  property :user_id, Integer, :nullable => false
  property :project_id, Integer, :nullable => false
  property :created_at, DateTime
  
  belongs_to :user
  belongs_to :project

  # Generate the instance of event. It's like a polymorphic system
  def ticket
    case eventable_class
    when "Ticket"
      Ticket.get(eventable_id)
    when "TicketUpdate"
      TicketUpdate.get(eventable_id).ticket
    when "Milestone"
      Milestone.get(eventable_id)
    end
  end

  def short_description
    ticket.title
  end

end
