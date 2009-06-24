class Ticket
  include DataMapper::Resource
  include DataMapper::Constraints
  
  property :id, Serial
  property :title, String, :nullable => false, :length => 255
  property :description, Text
  property :created_at, DateTime
  property :num, Integer, :nullable => false
  property :state_id, Integer, :nullable => false
  property :member_create_id, Integer, :nullable => false
  property :priority_id, Integer
  property :project_id, Integer

  belongs_to :project
  belongs_to :created_by, :model => "User", :child_key => [:member_create_id]
  belongs_to :assigned_to, :model => "User", :child_key => [:member_assigned_id], :nullable => true
  belongs_to :state
  belongs_to :priority
  belongs_to :milestone, :nullable => true

  has n, :ticket_updates, :constraint => :destroy

  has_tags
  has n, :tag_taggings, :model => "Tagging", :child_key => [:taggable_id], :taggable_type => self.to_s, :tag_context => "tags", :constraint => :destroy
  has n, :taggings, :model => "Tagging", :child_key => [:taggable_id], :taggable_type => self.to_s, :constraint => :destroy
  property :frozen_tag_list, String, :length => 255

  validates_with_method :users_in_members
  validates_with_method :milestone_in_same_project

  before :valid?, :define_num_ticket
  before :valid?, :define_state_new

  after :destroy, :delete_event_related

  def open
    all(:state_id => State.first(:name.not => 'closed').id)
  end

  def write_create_event
    Event.create(:eventable_class => self.class,
                 :eventable_id => self.id,
                 :user_id => member_create_id,
                 :event_type => :created,
                 :project_id => project_id)
  end

  def delete_event_related
    Event.all(:eventable_class => self.class.to_s,
              :eventable_id => self.id).each do |event|
      event.destroy
    end
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
    ticket[:member_assigned_id] = nil unless ticket[:member_assigned_id] # nil if not define
    ticket[:milestone_id] = nil unless ticket[:milestone_id] # nil if not define
    [:title, :state_id, :member_assigned_id, :priority_id, :milestone_id].each do |type_change|
      if send(type_change).to_s != ticket[type_change].to_s
        t.properties_update << [type_change, send(type_change), ticket[type_change]]
      end
    end

    ticket[:tag_list].downcase! if ticket[:tag_list]
    if frozen_tag_list != list_tag(ticket[:tag_list]).join(',')
      t.properties_update << [:tag_list, frozen_tag_list, list_tag(ticket[:tag_list]).join(',')]
    end
    tag_list = frozen_tag_list

    return true if t.description.nil? && t.properties_update.empty?
    if update(ticket)
      t.created_by = user
      if t.save
        t.write_event
        true
      end
    end
  end

  def self.paginate_by_search(q,  conditions={})
    unless q.empty?
      search_list = q.split(' ')
      conditions[:conditions] ||= [[]]
      new_tag ||= []
      search_list.each {|search_pattern|
        if search_pattern.include?(':')
          what, how = search_pattern.split(':')
          if what == 'tagged'
            if conditions['tag_taggings.tag.name']
              new_tag << how
            else
              conditions['tag_taggings.tag.name'] = how
            end
          elsif what == "state"
            # We can only search one state. Every time the last
            conditions['state.name'] = how
          end
        else
          conditions[:conditions][0] = conditions[:conditions][0] + [" (title LIKE ? OR description LIKE ?) "]
          conditions[:conditions] += ["%#{search_pattern}%", "%#{search_pattern}%"]
        end
      }
      if conditions[:conditions].size <= 1
        conditions.delete(:conditions)
      else
        conditions[:conditions][0] = conditions[:conditions][0].join(' AND ')
      end

      new_tag.each {|t|
        conditions[:id] ||= []
        tickets_with_tag = Ticket.all('tag_taggings.tag.name' => t).map(&:id)
        if tickets_with_tag.empty?
          return WillPaginate::Collection.new(1,10, 0) # Emulate a empty result because no result with a tag
        else
          conditions[:id] += tickets_with_tag
        end
      }

    end
    Ticket.paginate(conditions)
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
    Ticket.first(:num => permalink.to_i, :project_id => project_id.to_i)
  end

  # Return a Hash of tagging object
  # The key is the id number of tag and the value is an Array of Tagging
  # object. count the number of object and you know how Tag used is on a Tag
  def tag_counts
    Tagging.all(:taggable_id => id, :taggable_type => 'Ticket').group_by(&:tag_id)
  end

  private

  def define_num_ticket
    project  ||= Project.get(project_id)
    self.num ||= project.new_num_ticket
  end

  def define_state_new
    self.state_id ||= State.first(:name => 'new').id
  end

  def milestone_in_same_project
    return true if milestone.nil?
    if project_id != milestone.project_id
      [false, "The milestone need to be in same project of this ticket"]
    else
      true
    end
  end

end
