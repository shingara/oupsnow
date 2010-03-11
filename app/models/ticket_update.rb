class TicketUpdate

  include MongoMapper::EmbeddedDocument

  key :properties_update, Array
  key :description, String
  key :created_at, Time, :required => true
  key :creator_user_name, String, :required => true
  key :num, Integer, :required => true

  key :user_id, ObjectId
  belongs_to :user

  def write_event(ticket)
    Event.create(:eventable => ticket,
                 :user => user,
                 :event_type => :updated,
                 :project => ticket.project)
  end

  def add_update(type_change, old, new_value=nil)
    if old != new_value
      self.properties_update << [type_change, old, new_value]
    end
  end

  def add_tag_update(old, new_value)
    new_value.downcase! if new_value
    if Ticket.list_tag(old).join(',') != Ticket.list_tag(new_value).join(',')
      add_update(:tag_list, Ticket.list_tag(old).join(','), Ticket.list_tag(new_value).join(','))
    end
  end

  # We use num like params
  def to_param
    num.to_s
  end

  # TODO: need test
  def send_update_to_watchers
    _root_document.watchers.each do |watcher|
      UserMailer.deliver_ticket_update(_root_document.project, self, watcher)
    end
  end

end
