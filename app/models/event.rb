class Event
  include DataMapper::Resource
  
  property :id, Serial
  property :eventable_class, String, :nullable => false
  property :eventable_id, Integer, :nullable => false
  property :event_type, Enum[:created, :updated], :nullable => false
  property :user_id, Integer, :nullable => false
  property :project_id, Integer, :nullable => false
  property :created_at, DateTime
  
  belongs_to :user
  belongs_to :project

  def ticket
    if eventable_class == "Ticket"
      eval "#{eventable_class}.get(eventable_id)"
    elsif eventable_class == "TicketUpdate"
      p  "#{eventable_class}.get(eventable_id).ticket"
      eval "#{eventable_class}.get(eventable_id).ticket"
    end
  end

  def little_description
    ticket.title
  end

end
