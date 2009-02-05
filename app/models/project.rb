class Project
  include DataMapper::Resource
  include DataMapper::Constraints
  
  property :id, Serial
  property :name, String, :nullable => false, :unique => true
  property :description, Text

  has n, :tickets
  has n, :members 
  has n, :users, :through => :members
  has n, :functions, :through => :members
  has n, :events
  has n, :milestones

  before :destroy, :destroy_tickets
  before :destroy, :destroy_members
  before :destroy, :destroy_events
  before :destroy, :destroy_milestones

  def new_num_ticket
    max_num_ticket = tickets.max(:num)
    (max_num_ticket || 0).succ
  end

  # Destroy all ticket depend on this project
  # non needing when cascading come
  def destroy_tickets
    tickets.each{|t| t.destroy}
  end

  def destroy_events
    events.each{|e| e.destroy}
  end

  def destroy_members
    members.each{|m| m.destroy}
  end

  def destroy_milestones
    milestones.each{|m| m.destroy}
  end

end
