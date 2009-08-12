class Ticket
  include DataMapper::Resource
  include DataMapper::Constraints

  
  property :id, Serial
  property :title, String, :nullable => false, :length => 255
  property :description, Text
  property :created_at, DateTime
  property :updated_at, DateTime
  property :num, Integer, :nullable => false
  property :state_id, Integer, :nullable => false
  property :member_create_id, Integer, :nullable => false
  property :priority_id, Integer
  property :project_id, Integer

  belongs_to :project
  belongs_to :created_by, :class_name => "User", :child_key => [:member_create_id]
  belongs_to :assigned_to, :class_name => "User", :child_key => [:member_assigned_id]
  belongs_to :state
  belongs_to :priority
  belongs_to :milestone

  has n, :ticket_updates, :constraint => :destroy
  has n, :attachments, :constraint => :destroy

  has_tags
  has n, :tag_taggings, :class_name => "Tagging", :child_key => [:taggable_id], :taggable_type => self.to_s, :tag_context => "tags", :constraint => :destroy
  has n, :taggings, :class_name => "Tagging", :child_key => [:taggable_id], :taggable_type => self.to_s, :constraint => :destroy
  property :frozen_tag_list, String, :length => 255

  validates_with_method :users_in_members
  validates_with_method :milestone_in_same_project

  before :valid?, :define_num_ticket
  before :valid?, :define_state_new

  after :destroy, :delete_event_related

  attr_accessor :comment

  def open
    all(:state_id => State.first(:name.not => 'closed').id)
  end

  def write_create_event
    Event.create(:eventable_class => self.class,
                 :eventable_id => id,
                 :user_id => member_create_id,
                 :event_type => :created,
                 :project_id => project_id)
  end

  def delete_event_related
    Event.all(:eventable_class => self.class,
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
    t.properties_update = []
    ticket.each do |k,v|
      if k.to_sym == :description
        t.description = v unless v.blank?
        next
      end
      send("#{k}=", v)
    end

    changes = self.dirty_attributes

    changes.each do |property, new_value|
      field_sym = property.field.to_sym
      t.add_update(field_sym,
                   self.original_values[field_sym],
                   new_value)
    end
    t.add_tag_update(frozen_tag_list, ticket['tag_list'])

    return true if t.description.nil? && t.properties_update.empty?
    if save
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
            if conditions[:frozen_tag_list.like]
              new_tag << how
            else
              conditions[:frozen_tag_list.like] = "%#{how}%"
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
        tickets_with_tag = Ticket.all(:frozen_tag_list.like => "%#{t}%").map(&:id)
        if tickets_with_tag.empty?
          return WillPaginate::Collection.new(1,10, 0) # Emulate a empty result because no result with a tag
        else
          conditions[:id] += tickets_with_tag
        end
      }

    end
    Ticket.paginate(conditions)
  end

  def self.list_tag(string)
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
