class Ticket

  include MongoMapper::Document

  key :title, String, :required => true, :length => 255
  key :description, String
  key :num, Integer, :required => true
  key :tags, Set
  key :tag_list, String, :default => ''
  key :closed, Boolean, :default => false

  #It's all words in ticket. Usefull to full text search
  key :_keywords, Array, :required => true


  ## denormalisation
  key :priority_name, String
  key :milestone_name, String
  key :creator_user_name, String, :required => true
  key :state_name, String, :required => true
  key :user_assigned_name, String, :default => ''

  many :ticket_updates
  many :attachments


  key :user_creator_id, ObjectId, :required => true
  key :project_id, ObjectId
  key :state_id, ObjectId
  key :user_assigned_id, ObjectId
  key :milestone_id, ObjectId
  key :priority_id, ObjectId

  timestamps!

  belongs_to :project
  belongs_to :state
  belongs_to :user_assigned,
    :class_name => 'User'
  belongs_to :milestone
  belongs_to :user_creator,
    :class_name => 'User'
  belongs_to :priority

  # WARNING: what's happen if another event has same id ?
  many :events,
    :class_name => 'Event',
    :foreign_key => :eventable_id,
    :dependent => :destroy

  validates_true_for :created_user_ticket,
    :logic => lambda { users_in_members },
    :message => 'The user to assigned ticket need member of project'
  validates_true_for :milestone_ticket,
    :logic => lambda { milestone_in_same_project },
    :message => "The milestone need to be in same project of this ticket"
  validates_true_for :num,
    :logic => lambda { num_already_used_in_same_project },
    :message => "is already used in same project"

  before_validation_on_create :define_num_ticket
  before_validation :define_state_new
  before_validation :copy_user_creator_name
  before_validation :update_tags
  before_validation :update_priority
  before_validation :update_num_of_ticket_updates

  before_save :update_milestone_name
  before_save :update_user_assigned_name
  before_save :update_keyworkds

  after_save :update_project_tag_counts
  after_save :update_milestone_tickets_count

  attr_accessor :comment

  def open
    all(:state_id => State.first(:name.not => 'closed').id)
  end

  ## TODO: change name to create_event
  def write_create_event
    Event.create(:eventable => self,
                 :user => user_creator,
                 :event_type => :created,
                 :project => project)
  end

  ##
  # with a ticket and a user, check difference between ticket send by params
  # and this ticket. If there are difference, generate a ticket_updates to this ticket
  #
  # @params[Hash] a hash with new value to see difference between this
  # @params[User] user submit new change
  # @return[Boolean] true if ticket_update created. False
  def generate_update(ticket, user)
    t = TicketUpdate.new
    unless ticket[:description].blank?
      t.description = ticket[:description]
    end

    if Ticket.list_tag(ticket[:tag_list]) != Ticket.list_tag(self.tag_list)
      t.add_update(:tag_list,
                   Ticket.list_tag(self.tag_list),
                   Ticket.list_tag(ticket[:tag_list]))
      self.tag_list = ticket[:tag_list]
    end

    [[:state_id, State],
      [:priority_id, Priority],
      [:milestone_id, Milestone],
      [:user_assigned_id, User]].each do |property|
      if ticket[property[0]].to_s != self.send(property[0]).to_s
        property_klass = property[0].to_s.gsub('_id', '')
        new_value = property[1].find(ticket[property[0]])
        t.add_update(property_klass.to_sym,
                     send(property_klass) ? send(property_klass).name : '',
                     new_value ? new_value.name : '')
        self.send("#{property[0]}=", ticket[property[0]])
      end
    end

    # no change and description empty
    return if t.description.blank? && t.properties_update.empty?
    t.user = user
    t.creator_user_name = user.login
    t.created_at = Time.now
    t.write_event(self)
    ticket_updates << t
    save!
  end

  ##
  # Search by query with pagination available
  #
  # @params[q] the string with search
  # @params[conditions] conditions with pagination options
  def self.paginate_by_search(q, conditions={})
    query_conditions ||={}
    unless q.empty?
      query_conditions = {}
      q.split(' ').each {|v|
        key = nil
        if v.include?(':')
          s = v.split(':')
          if s[0] == 'state'
            query_conditions[:state_name] = s[1]
          elsif s[0] == 'tagged'
            query_conditions[:tags] ||= []
            query_conditions[:tags] << s[1]
          else
            p 'no what'
          end
        else
          query_conditions[:_keywords] ||= {'$all' => []}
          query_conditions[:_keywords]['$all'] <<  v
        end
      }
    end
    if query_conditions['tags'] && query_conditions['tags'].size > 1
      query_conditions['tags'] = {'$all' => query_conditions['tags']}
    end
    conditions.merge!(query_conditions)
    Ticket.paginate(conditions)
  end

  def self.new_by_params(params, project, user)
    params.delete(:milestone_id) if params[:milestone_id].blank?
    ticket = Ticket.new(params)
    ticket.project_id = project._id
    ticket.user_creator = user
    ticket
  end

  def self.list_tag(string)
    string.to_s.split(',').map { |name|
      name.gsub(/[^\w_-]/i, '').strip
    }.uniq.sort
  end

  def ticket_permalink
    "#{num}"
  end

  ##
  # get ticket with num and project_id
  #
  # @params[String] project_id where find this ticket
  # @params[String] permalink of this ticket (number of this ticket) in this project
  def self.get_by_permalink(project_id, permalink)
    Ticket.first({:num => permalink.to_i, :project_id => project_id})
  end

  ##
  # Return a Hash of tagging object
  # The key is the id number of tag and the value is an Array of Tagging
  # object. count the number of object and you know how Tag used is on a Tag
  #
  # TODO: need some test
  # FIXME: see how use same with milestone and project method like a module ?
  def tag_counts
    res = {}
    tags.each do |t|
      res[t] = 1
    end
    res
  end

  ##
  # get ticket_update with this num
  #
  # @params[id] number of ticket_update what you search
  # @return[TicketUpdate] the ticket update with num define in params or nil
  def get_update(num)
    ticket_updates.detect{ |tu|
      tu.num.to_i == num.to_i
    }
  end

  def to_param
    num.to_s
  end

  private

  # get number of this ticket in project model
  def define_num_ticket
    self.num ||= project.new_num_ticket
  end

  def define_state_new
    self.state_id ||= State.first(:conditions => {:name => 'new'}).id
    self.state = State.find(self.state_id)
    self.state_name = self.state.name
    self.closed = self.state.closed
    true
  end

  def milestone_in_same_project
    return true unless milestone_id
    not project_id != milestone.project_id
  end

  def users_in_members
    return true if user_assigned_id.blank?
    project.has_member?(user_assigned)
  end

  def copy_user_creator_name
    self.creator_user_name ||= self.user_creator.login
  end

  def update_tags
    self.tags = Ticket.list_tag(self.tag_list)
  end

  def update_priority
    self.priority_name = self.priority.name
  end

  def no_dirty
    @dirty_attributes = {}
  end

  ##
  # check if num of ticket is already used in project
  #
  def num_already_used_in_same_project
    Ticket.first(:conditions => {:project_id => self.project_id,
                 :num => self.num,
                  :_id => {'$ne' => self._id}}).nil?
  end

  ##
  # Define a number of each ticket_update
  def update_num_of_ticket_updates
    ticket_updates.each_with_index do |tu, i|
      tu.num ||= (i+1)
    end
  end

  ##
  # Update tag_counts on project where is this ticket
  #
  def update_project_tag_counts
    project.update_tag_counts
  end

  ##
  # Update the milestone_name field with milestone name if
  # milestone is define
  #
  def update_milestone_name
    if self.milestone || self.milestone_id
      self.milestone_name = self.milestone.name
    else
      self.milestone_name = ''
    end
  end

  ##
  # Update the user_assigned_name field with user_assigned name if
  # user_assigned is define
  #
  def update_user_assigned_name
    if self.user_assigned || self.user_assigned_id
      self.user_assigned_name = self.user_assigned.login
    else
      self.user_assigned_name = ''
    end
  end

  # update milestone information about this ticket
  # TODO: what's happen if milestone change ?
  def update_milestone_tickets_count
    self.milestone.update_nb_tickets_count
  end

  def update_keyworkds
    self._keywords = self.title.split(/\W+/)
    self._keywords += self.description.split(/\W+/) unless self.description.blank?
    self._keywords += self.tag_list.split(',') unless self.tag_list.blank?
    self.ticket_updates.each do |tu|
      self._keywords += tu.description.split(/\W+/) unless tu.description.blank?
    end
    self._keywords = self._keywords.flatten.uniq.sort
  end

end
