class TicketUpdate

  include MongoMapper::EmbeddedDocument

  key :properties_update, String, :default => []
  key :description, String
  key :created_at, DateTime
  key :creator_name, String, :required => true

  belongs_to :user

  def write_event(ticket)
    Event.create(:eventable => ticket,
                 :user => user,
                 :event_type => :updated,
                 :project => ticket.project)
  end

  def add_update(type_change, old, new_value=nil)
    if old.to_s != new_value.to_s
      self.properties_update << [type_change, old, new_value]
    end
  end

  def add_tag_update(old, new_value)
    new_value.downcase! if new_value
    if old != Ticket.list_tag(new_value).join(',')
      add_update(:tag_list, old, Ticket.list_tag(new_value).join(','))
    end
  end

end
