class Ticket
  include DataMapper::Resource
  
  property :id, Serial
  property :title, String, :nullable => false
  property :description, Text
  property :created_at, DateTime
  property :num, Integer, :nullable => false
  property :state_id, Integer, :nullable => false

  belongs_to :project
  belongs_to :member
  belongs_to :state
  has n, :ticket_update

  has_tags

  before :valid?, :define_num_ticket
  before :valid?, :define_state_new

  def define_num_ticket
    self.num = project.new_num_ticket if self.num.nil?
  end

  def define_state_new
    self.state_id = State.first(:name => 'new').id if self.state_id.nil?
  end


end
