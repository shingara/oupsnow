class TicketUpdate

  include MongoMapper::EmbeddedDocument

  key :properties_update, String, :default => []
  key :description, String
  key :created_at, DateTime
  key :user_name, String

  belongs_to :user

  def write_event
    Event.create(:eventable_class => self.class,
                 :eventable_id => self.id,
                 :user_id => self.member_create_id,
                 :event_type => :updated,
                 :project_id => self.ticket.project_id)
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
