class Project
  include DataMapper::Resource
  include DataMapper::Constraints
  
  property :id, Serial
  property :name, String, :nullable => false, :unique => true
  property :description, Text

  has n, :tickets, :constraint => :destroy
  has n, :members 
  has n, :users, :through => :members, :constraint => :destroy
  has n, :functions, :through => :members, :constraint => :destroy
  has n, :events, :constraint => :destroy
  has n, :milestones, :constraint => :destroy

  validates_with_method :have_one_admin
  validates_with_method :have_member

  def new_num_ticket
    max_num_ticket = tickets.max(:num)
    (max_num_ticket || 0).succ
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

  def has_member?(user)
    members.count(:user_id => user.id) > 0
  end

  #TODO: need spec about this function
  def add_member(user, function)
    members.create(:function_id => function.id,
                 :user_id => user.id)
  end

  def current_milestone
    milestones.first(:expected_at.gt => Time.now, :order => [:expected_at])
  end

  def outdated_milestones
    milestones.all(:expected_at.lt => Time.now,
                   :id.not => current_milestone ? current_milestone.id : 0,
                   :order => [:expected_at.desc])
  end

  def upcoming_milestones
    milestones.all(:expected_at.gt => Time.now, 
                   :id.not => current_milestone ? current_milestone.id : 0,
                   :order => [:expected_at])
  end
  
  def no_date_milestones
    milestones.all(:expected_at => nil,
                   :id.not => current_milestone ? current_milestone.id : 0)
  end

  # Return a Hash of tagging object
  # The key is the id number of tag and the value is an Array of Tagging
  # object. count the number of object and you know how Tag used is on a Tag
  def ticket_tag_counts
    Tagging.all(:taggable_id => tickets.map(&:id), :taggable_type => 'Ticket').group_by(&:tag_id)
  end

end
