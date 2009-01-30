class Milestone
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  property :description, Text
  property :expected_at, Date

  belongs_to :project

  def write_event_create(user)
    Event.create(:eventable_class => self.class,
                 :eventable_id => id,
                 :user_id => user.id,
                 :event_type => :created,
                 :project_id => project_id)
  end

  alias_method :title, :name


end
