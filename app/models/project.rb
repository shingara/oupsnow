class Project
  include DataMapper::Resource
  include DataMapper::Constraints
  
  property :id, Serial
  property :name, String, :nullable => false, :unique => true
  property :description, Text

  has n, :tickets
  has n, :members 
  has n, :users, :through => :members
  has n, :functions, :through => :members
  has n, :events
  has n, :milestones

  before :destroy, :destroy_tickets
  before :destroy, :destroy_members
  before :destroy, :destroy_events
  before :destroy, :destroy_milestones

  validates_with_method :have_one_admin
  validates_with_method :have_member

  def new_num_ticket
    max_num_ticket = tickets.max(:num)
    (max_num_ticket || 0).succ
  end

  # Destroy all ticket depend on this project
  # non needing when cascading come
  def destroy_tickets
    tickets.each{|t| t.destroy}
  end

  def destroy_events
    events.each{|e| e.destroy}
  end

  def destroy_members
    members.each{|m| m.destroy}
  end

  def destroy_milestones
    milestones.each{|m| m.destroy}
  end

  def have_one_admin
    unless members.any? {|m| m.function.project_admin}
      return [false, 'The project need a admin']
    else
      return true
    end
  end

  def have_member
    if members.empty?
      return [false, 'The project need a member']
    else
      return true
    end
  end

  def current_milestone
    milestones.first(:expected_at.gt => Time.now, :order => [:expected_at])
  end

  def outdated_milestones
    milestones.all(:expected_at.lt => Time.now, :order => [:expected_at.desc])
  end

  def upcoming_milestones
    milestones.all(:expected_at.gt => Time.now, :order => [:expected_at])
  end
  
  def no_date_milestones
    milestones.all(:expected_at => nil)
  end

  # Return a Hash of tagging object
  # The key is the id number of tag and the value is an Array of Tagging
  # object. count the number of object and you know how Tag used is on a Tag
  def ticket_tag_counts
    Tagging.all(:taggable_id => tickets.map(&:id), :taggable_type => 'Ticket').group_by(&:tag_id)
  end

end
