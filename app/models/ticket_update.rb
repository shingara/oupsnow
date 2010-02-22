class TicketUpdate

  include Mongoid::Document
  include Mongoid::Timestamps

  field :properties_update, :type =>Array
  field :description
  field :creator_user_name
  field :num, :type => Integer

  belongs_to_related :user

  index :user_id

  validates_presence_of :created_at
  validates_presence_of :creator_user_name
  validates_presence_of :num

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

end
