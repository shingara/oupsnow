class Ticket

  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, :type => String, :length => 255
  field :description, :type => String
  field :num, :type => Integer#, :required => true
  field :tag_list, :type => String, :default => ''

  #It's all words in ticket. Useful to full text search
  field :_keywords, :type => Array
  field :tags, :type => Set

  ## denormalisation
  field :priority_name, :type => String
  field :milestone_name, :type => String
  field :creator_user_name, :type => String
  field :state_name, :type => String
  field :closed, :type => Boolean, :default => false
  field :user_assigned_name, :type => String, :default => ''

  embeds_many :watchers
  #include_errors_from :watchers
  embeds_many :ticket_updates
  embeds_many :attachments


  field :user_creator_id, :type => BSON::ObjectID
  field :project_id, :type => BSON::ObjectID
  field :state_id, :type => BSON::ObjectID
  field :user_assigned_id, :type => BSON::ObjectID
  field :milestone_id, :type => BSON::ObjectID
  field :priority_id, :type => BSON::ObjectID


  #timestamps!

  belongs_to_related :project
  belongs_to_related :state
  belongs_to_related :user_assigned,
    :class_name => 'User'
  belongs_to_related :milestone
  belongs_to_related :user_creator,
    :class_name => 'User'
  belongs_to_related :priority

  # WARNING: what's happen if another event has same id ?
  has_many_related :events,
    :class_name => 'Event',
    :foreign_key => :eventable_id,
    :dependent => :destroy



  validate :users_in_members
  validate :milestone_in_same_project
  validate :num_already_used_in_same_project

  validates_presence_of :num
  validates_presence_of :_keywords
  validates_presence_of :creator_user_name
  validates_presence_of :state_name
  validates_presence_of :user_creator_id
  validates_presence_of :title

  before_validation :define_num_ticket, :on => :create
  before_validation :define_state_new
  before_validation :copy_user_creator_name
  before_validation :update_tags
  before_validation :update_priority
  before_validation :update_num_of_ticket_updates
  before_validation :update_watcher
  before_validation :update_keywords

  before_save :update_milestone_name
  before_save :update_user_assigned_name

  after_save :update_tag_counts
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
                   Ticket.list_tag(self.tag_list).join(','),
                   Ticket.list_tag(ticket[:tag_list]).join(','))
      self.tag_list = ticket[:tag_list].try(:downcase)
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
    t.send_update_to_watchers if save
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
            query_conditions[:tags] << s[1].downcase
          elsif s[0] == 'closed'
            query_conditions[:closed] = (s[1] == 'true')
          else
            p 'no what'
          end
        else
          query_conditions[:_keywords] ||= {'$all' => []}
          query_conditions[:_keywords]['$all'] <<  v.downcase
        end
      }
    end
    if query_conditions['tags'] && query_conditions['tags'].size > 1
      query_conditions['tags'] = {'$all' => query_conditions['tags']}
    end
    conditions.merge!(query_conditions)
    Ticket.paginate(conditions.reverse_merge(:page => 1, :per_page => 10))
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
      name.gsub(/[^\w_-]/i, '').strip.downcase
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

  def unwatch(user)
    self.watchers.delete_if{|watcher| watcher.user_id == user.id }
  end

  def watchers?(user)
    self.watchers.any?{|watcher| watcher.user_id == user.id }
  end

  private

  # get number of this ticket in project model
  def define_num_ticket
    p project
    p project.new_num_ticket
    p self.num
    self.num ||= project.new_num_ticket
    p self.num
  end

  def define_state_new
    self.state_id ||= State.first(:conditions => {:name => 'new'}).id
    self.state = State.find(self.state_id)
    self.state_name = self.state.name
    self.closed = self.state.closed
    true
  end

  def milestone_in_same_project
    #:message => "The milestone need to be in same project of this ticket"
    return true unless milestone_id
    not project_id != milestone.project_id
  end

  def users_in_members
   #  :user_assigned,
   #  :logic => lambda { users_in_members },
   #  :message => 'need to be member of project'
    p 'validate'
    return true if user_assigned_id.blank?
    project.has_member?(user_assigned_id)
  end

  def copy_user_creator_name
    self.creator_user_name ||= self.user_creator.login
  end

  def update_tags
    self.tags = Ticket.list_tag(self.tag_list)
    self.tag_list = self.tag_list.downcase
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

    # validates_true_for :num,
    #   :logic => lambda { num_already_used_in_same_project },
    #   :message => "is already used in same project"
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
  def update_tag_counts
    project.update_tag_counts
    milestone.update_tag_counts if milestone
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

  def update_keywords
    self._keywords = self.title.split(/\W+/)
    self._keywords += self.description.split(/\W+/) unless self.description.blank?
    self._keywords += self.tag_list.split(',') unless self.tag_list.blank?
    self.ticket_updates.each do |tu|
      self._keywords += tu.description.split(/\W+/) unless tu.description.blank?
    end
    self._keywords = self._keywords.flatten.map(&:downcase).uniq.sort
  end

  # Define the email of watcher if not define
  def update_watcher
    self.watchers.each do |watcher|
      watcher.email ||= watcher.user.email
      watcher.login ||= watcher.user.login
    end
  end

end
