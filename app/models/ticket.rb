class Ticket
  include DataMapper::Resource
  
  property :id, Serial
  property :title, String, :nullable => false
  property :description, Text
  property :created_at, DateTime
  property :num, Integer, :nullable => false
  property :state_id, Integer, :nullable => false
  property :member_create_id, Integer, :nullable => false
  property :priority_id, Integer

  belongs_to :project
  belongs_to :created_by, :class_name => "User", :child_key => [:member_create_id]
  belongs_to :assigned_to, :class_name => "User", :child_key => [:member_assigned_id]
  belongs_to :state
  belongs_to :priority
  has n, :ticket_updates

  has_tags

  validates_with_method :users_in_members

  before :valid?, :define_num_ticket
  before :valid?, :define_state_new

  before :destroy, :delete_ticket_updates

  after :create, :write_event

  def write_event
    Event.create(:eventable_class => self.class,
                 :eventable_id => id,
                 :user_id => member_create_id,
                 :event_type => :created,
                 :project_id => project_id)
  end

  def delete_ticket_updates
    ticket_updates.each {|tu| tu.destroy}
  end

  def users_in_members
    unless member_assigned_id.nil?
      if Member.first(:user_id => member_assigned_id,
                      :project_id => project_id).nil?
        errors.add(:assigned_to, 'The user to assigned ticket need member of project')
        return false
      end
    end
    return true
  end

  def generate_update(ticket, user)
    t = ticket_updates.new
    #TODO: see why, by default is not created with default value. Bug ???
    t.properties_update = []
    unless ticket[:description].blank?
      t.description = ticket[:description]
      ticket.delete(:description)
    end
    [:title, :state_id, :member_assigned_id, :priority_id].each do |type_change|
      #TODO: see better than eval
      if eval("#{type_change}").to_s != ticket[type_change.to_sym].to_s
        t.properties_update << [type_change, send(type_change), ticket[type_change]]
      end
    end

    #TODO: no update if no same order
    #TODO: no update if several space

    if frozen_tag_list != list_tag(ticket[:tag_list]).join(',')
      t.properties_update << [:tag_list, frozen_tag_list, list_tag(ticket[:tag_list]).join(',')]
    end
    tag_list = frozen_tag_list

    return true if t.description.nil? && t.properties_update.empty?
    if update_attributes(ticket)
      t.created_by = user
      bool_return = t.save
      Event.create(:eventable_class => t.class,
                   :eventable_id => t.id,
                   :user_id => member_create_id,
                   :event_type => :updated,
                   :project_id => project_id)
      bool_return
    end
  end

  def list_tag(string)
    string.to_s.split(',').map { |name| 
      name.gsub(/[^\w_-]/i, '').strip 
    }.uniq.sort
  end

  def ticket_permalink
    "#{num}"
  end

  def self.get_by_permalink(project_id, permalink)
    Ticket.first(:num => permalink, :project_id => project_id)
  end

  private

  def define_num_ticket
    project = Project.get(project_id) if project.nil?
    self.num = project.new_num_ticket if self.num.nil?
  end

  def define_state_new
    self.state_id = State.first(:name => 'new').id if self.state_id.nil?
  end

end
