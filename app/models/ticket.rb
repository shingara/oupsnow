class Ticket

  include MongoMapper::Document
  
  key :title, String, :required => true, :length => 255
  key :description, String
  key :created_at, DateTime, :required => true
  key :updated_at, DateTime, :required => true
  key :num, Integer, :required => true
  key :project_id, String, :required => true
  key :tags, Array

  key :created_user_name, String

  key :priority_ticket, Array, :length => 2 #[priority_name, priority_id]
  key :milestone_ticket, Array, :length => 2 #[milestone_name, milestone_id]

  many :ticket_updates
  many :attachments

  belongs_to :project
  belongs_to :state
  belongs_to :member_assigned, :class => User
  belongs_to :milestone
  belongs_to :created_user, :class => User

  validates_true_for :created_user_ticket, :logic => lambda { users_in_members }, 
    :message => 'The user to assigned ticket need member of project'
  validates_true_for :milestone_ticket, :logic => lambda { milestone_in_same_project },
    :message => "The milestone need to be in same project of this ticket"

  before_validation :define_num_ticket
  before_validation :define_state_new

  after_destroy :delete_event_related

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
    self.num ||= project.new_num_ticket
  end

  def define_state_new
    self.state ||= State.first(:name => 'new')
  end

  def milestone_in_same_project
    return true if milestone.nil?
    not project_id != milestone.project_id
  end

end
