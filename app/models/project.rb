class Project
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :nullable => false, :unique => true
  property :description, Text

  has n, :tickets
  has n, :members 
  has n, :users, :through => :members
  has n, :functions, :through => :members

  after :destroy, :destroy_tickets

  def new_num_ticket
    max_num_ticket = tickets.max(:num)
    if max_num_ticket.nil?
      1
    else
      max_num_ticket.succ
    end
  end

  # Destroy all ticket depend on this project
  # non needing when cascading come
  def destroy_tickets
    Ticket.all(:project_id => id).destroy!
  end

end
