class Milestone
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  property :description, Text
  property :expected_at, Date

  belongs_to :project

  has n, :tickets

  def write_event_create(user)
    Event.create(:eventable_class => self.class,
                 :eventable_id => id,
                 :user_id => user.id,
                 :event_type => :created,
                 :project_id => project_id)
  end

  alias_method :title, :name

  def percent_complete
    return 0 if tickets.size == 0
    ((ticket_open.to_f / tickets.size.to_f) * 100).to_f
  end

  def ticket_open
    tickets.count(:state_id.not => State.first(:name => 'closed').id)
  end

  def ticket_closed
    #TODO: define a closed state to all state
    tickets.count(:state_id => State.first(:name => 'closed').id)
  end


end
