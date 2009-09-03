class Project

  include MongoMapper::Document
  
  key :name, String, :unique => true
  key :description, String
  key :created_at, DateTime
  key :num_ticket, Integer, :default => 1

  many :project_members
  many :milestones

  validates_true_for :project_members, :logic => lambda { have_one_admin }, :message => 'need an admin'

  validates_presence_of :name

  def new_num_ticket
    old_num = num_ticket
    num_ticket.succ
    save
    old_num
  end

  def have_one_admin
    project_members.any? {|m| m.project_admin?}
  end

  def have_member
    not members.empty?
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
    tickets.taggings.all.group_by(&:tag_id)
  end

end
