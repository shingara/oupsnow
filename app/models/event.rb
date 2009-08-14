class Event

  include MongoMapper::Document

  key :created_at, DateTime

  key :type_event, Array #[type_event_name, type_id]
  key :user_event, Array #[user_name, user_id]
  key :project_event, Array #[project_name, project_id]

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
