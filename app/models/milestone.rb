class Milestone

  include Mongoid::Document

  field :name, :type => String, :required => true
  field :description, :type => String
  field :expected_at, :type => Date

  # denormalisation
  field :nb_tickets_open, :type => Integer, :default => 0
  field :nb_tickets_closed, :type => Integer, :default => 0
  field :nb_tickets, :type => Integer, :default => 0
  field :tag_counts, :type => Hash

  has_many_related :tickets

  field :project_id, :type => BSON::ObjectID
  validates_presence_of :project_id
  belongs_to_related :project

  after_save :check_current_milestone

  ##
  # Create a event about creation of this milestone
  #
  # TODO: need test
  #
  # @params[User] user to create this milestone
  def write_event_create(user)
    Event.create(:eventable => self,
                 :user => user,
                 :event_type => :created,
                 :project => self.project)
  end

  alias_method :title, :name

  def percent_complete
    return 0 if nb_tickets == 0
    100.0 * nb_tickets_closed / nb_tickets
  end

  ##
  # Ticket open in this milestone
  #
  # TODO: need test
  #
  # @return[Array] all tickets in this milestone not closed
  def ticket_open
    tickets.all(:conditions => {:closed => false})
  end

  ##
  # number of ticket closed in this milestone
  #
  # TODO: need test
  #
  # @return[Integer] number of ticket closed on this milestone
  def ticket_closed_count
    tickets.count( :conditions => {:closed => true})
  end

  ##
  # check all tag of all tickets on this project.
  # Generate the tag_counts field
  #
  # This method is used in callback after ticket update.
  # Can be push in queue
  #
  def update_tag_counts
    tag_counts = {}
    tickets.all.map{|t| t.tags.to_a }.flatten.each do |tag|
      if tag_counts[tag]
        tag_counts[tag] += 1
      else
        tag_counts[tag] = 1
      end
    end
    self.tag_counts = tag_counts
    save!
  end

  def update_nb_tickets_count
    self.nb_tickets_open = tickets.where({:closed => false}).count
    self.nb_tickets_closed = tickets.where({:closed => true}).count
    self.nb_tickets = self.nb_tickets_open + self.nb_tickets_closed
    self.save!
  end

  ##
  # Define Milestone like current if no other define before
  def check_current_milestone
    is_current_milestone unless project.current_milestone_id
  end

  def current
    self.project.current_milestone_id == self.id
  end

  def current=(current)
    is_current_milestone if current.eql?('1') || current == true
  end


  private

  def is_current_milestone
    project.current_milestone = self
    project.save!
  end

end
