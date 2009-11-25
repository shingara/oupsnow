class Milestone

  include MongoMapper::Document

  key :name, String
  key :description, String
  key :expected_at, Date


  # denormalisation
  key :nb_tickets_open, Integer, :default => 1 # TODO: need callback to update it
  key :nb_tickets_closed, Integer, :default => 1 # TODO: need callback to update it
  key :nb_tickets, Integer, :default => 1 # TODO: need callback to update it

  many :tickets

  key :project_id, ObjectId
  belongs_to :project

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
  # Number of ticket allways open
  #
  # TODO: use only in callback
  # TODO: need some test
  #
  # return[Integer] number of ticket open
  def ticket_open_count
    tickets.count(:conditions => {:closed => false})
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
  # Return a Hash of tagging object
  # The key is the id number of tag and the value is an Array of Tagging
  # object. count the number of object and you know how Tag used is on a Tag
  #
  # TODO: need some test
  # TODO: see refactoring because same code of Project#ticket_tag_counts
  #
  # @return[Hash] Hash with name of tag in key. and number of tag use in this project in value
  def tag_counts
    tag_list = []
    tickets.all.each do |t|
      tag_list = t.tags
    end
    res = {}
    tag_list.each do |v|
      res[v] = res[v] ? res[v].inc : 1
    end
    res
  end

end
