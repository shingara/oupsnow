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
  has n, :ticket_updates

  has_tags

  before :valid?, :define_num_ticket
  before :valid?, :define_state_new

  def generate_update(ticket)
    t = ticket_updates.build
    #TODO: see why, by default is not created with default value. Bug ???
    t.properties_update = []
    unless ticket[:description].blank?
      t.description = ticket[:description]
      ticket.delete(:description)
    end
    [:title, :state_id, :member_id].each do |type_change|
      #TODO: see better than eval
      if eval("#{type_change}").to_s != ticket[type_change.to_sym]
        t.properties_update << [type_change, send(type_change), ticket[type_change]]
      end
    end
    t.save
    update_attributes(ticket)
  end

  private

  def define_num_ticket
    self.num = project.new_num_ticket if self.num.nil?
  end

  def define_state_new
    self.state_id = State.first(:name => 'new').id if self.state_id.nil?
  end

end
