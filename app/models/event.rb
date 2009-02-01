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

  # Generate the instance of event. It's like a polymorphic system
  # 
  # TODO: We can use Eval(eventable_class) or Module.const_get(eventable_class).
  # If we have time test a benchmarck
  def ticket
    case eventable_class
    when "Ticket"
      Module.const_get(eventable_class).get(eventable_id)
    when "TicketUpdate"
      Module.const_get(eventable_class).get(eventable_id).ticket
    when "Milestone"
      Module.const_get(eventable_class).get(eventable_id)
    end
  end

  def short_description
    ticket.title
  end

end
