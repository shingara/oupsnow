class Ticket

  include MongoMapper::Document
  
  key :title, String, :required => true, :length => 255
  key :description, String
  key :num, Integer, :required => true
  key :tags, Array
  key :tag_list, String
  key :state_name, String, :required => true

  key :_keywords, Array, :required => true #It's all words in ticket. Usefull to full text search

  key :creator_user_name, String, :required => true

  key :priority_name, String
  key :milestone_name, String

  [:title, :description, :tag_list, :state_name, :priority_name, :milestone_name].each do |tr|
    eval <<-end_eval
      def #{tr}=(value)
        @dirty_attributes ||={}
        if @dirty_attributes[:#{tr}]
          @dirty_attributes[:#{tr}][1] = value
        else
          @dirty_attributes[:#{tr}] = [read_attribute(:#{tr}), value]
        end
        write_attribute(:'#{tr}', value)
      end
    end_eval
  end
  after_save :no_dirty

  many :ticket_updates
  many :attachments

  key :user_creator_id, String
  key :project_id, String
  key :state_id, String
  key :user_assigned_id, String
  key :milestone_id, String

  timestamps!


  belongs_to :project
  belongs_to :state
  belongs_to :user_assigned, :class_name => 'User'
  belongs_to :milestone
  belongs_to :user_creator, :class_name => 'User', :required => true

  validates_true_for :created_user_ticket, 
    :logic => lambda { users_in_members }, 
    :message => 'The user to assigned ticket need member of project'
  validates_true_for :milestone_ticket, 
    :logic => lambda { milestone_in_same_project },
    :message => "The milestone need to be in same project of this ticket"

  before_validation :define_num_ticket
  before_validation :define_state_new
  before_validation :copy_user_creator_name
  before_validation :update_tags

  after_destroy :delete_event_related

  attr_accessor :comment

  def open
    all(:state_id => State.first(:name.not => 'closed').id)
  end

  def write_create_event
    Event.create(:eventable => self,
                 :user => user_creator,
                 :event_type => :created,
                 :project => project)
  end

  def delete_event_related
    Event.all(:eventable => self.class).each do |event|
      event.destroy
    end
  end

  def to_hash
    h = {}
    self.class.keys.keys.collect do |name|
      h[name] = read_attribute(name)
    end
    h
  end

  def generate_update(ticket, user)
    t = TicketUpdate.new
    to_hash.diff(ticket).each_key do |property|
      if property.to_sym == :description
        t.description = ticket[:description]
        ticket.delete(:description)
        next
      end
      t.add_update(property,
                   send(property),
                   ticket[property])
    end
    p t
    # no change and description empty
    if t.description.blank? && t.properties_update.empty?
      return
    end
    t.user = user
    t.creator_name = user.login
    t.write_event(self)
    ticket_updates << t
    update_attributes(ticket)
    save
  end

  ##
  # Search by query with pagination available
  #
  # @params[q] the string with search
  # @params[conditions] conditions with pagination options
  def self.paginate_by_search(q,  conditions={})
    query_conditions ||={}
    unless q.empty?
      query_conditions = {}
      q.split(' ').each {|v|
        key = nil
        if v.include?(':')
          s = v.split(':')
          if s[0] == 'state'
            query_conditions['state_name'] = s[1]
          elsif s[0] == 'tagged'
            query_conditions['tags'] ||= []
            query_conditions['tags'] << s[1]
          else
            p 'no what'
          end
        else
          query_conditions['_keywords'] = v
        end
      }
    end
    if query_conditions['tags'] && query_conditions['tags'].size > 1
      query_conditions['tags'] = {'$all' => query_conditions['tags']}
    end
    conditions[:conditions] = query_conditions
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
    self.state_name = self.state.name
  end

  def milestone_in_same_project
    return true unless milestone_id?
    not project_id != milestone.project_id
  end

  def users_in_members
    return true unless user_assigned_id?
    project.has_member?(user_assigned)
  end

  def copy_user_creator_name 
    self.creator_user_name ||= self.user_creator.login
  end

  def update_tags
    self.tags = Ticket.list_tag(self.tag_list)
  end

  def no_dirty
    @dirty_attributes = {}
  end

end
