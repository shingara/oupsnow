class Event

  include MongoMapper::Document

  ### PROPERTY ###
  
  key :user_name, String
  key :eventable_class, String
  key :eventable_id, String
  
  ### Association ###
  
  key :user_id, String
  key :project_id, String
  key :eventable_type, String
  key :eventable_id, String

  belongs_to :user
  belongs_to :project
  belongs_to :eventable, :polymorphic => true, :dependent => :destroy

  # TODO: need test about created_at/updated_at needed
  timestamps!

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
