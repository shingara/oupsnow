class Milestone

  include MongoMapper::Document

  key :name, String, :required => true
  key :description, String
  key :expected_at, Date

  # denormalisation
  key :nb_tickets_open, Integer, :default => 0
  key :nb_tickets_closed, Integer, :default => 0
  key :nb_tickets, Integer, :default => 0
  key :tag_counts, Hash

  many :tickets

  key :project_id, ObjectId, :required => true
  belongs_to :project

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
    self.nb_tickets_open = tickets.count(:conditions => {:closed => false})
    self.nb_tickets_closed = tickets.count(:conditions => {:closed => true})
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
