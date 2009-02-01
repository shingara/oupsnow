class Project
  include DataMapper::Resource
  
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
    events.destroy!
  end

  def destroy_members
    members.each{|m| m.destroy}
  end

end
