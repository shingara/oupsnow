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

  # Destroy all ticket depend on this project
  # non needing when cascading come
  def destroy_tickets
    Ticket.all(:project_id => id).destroy!
  end

end
