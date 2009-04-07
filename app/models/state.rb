class State
  include DataMapper::Resource
  include DataMapper::Constraints
  
  property :id, Serial
  property :name, String, :nullable => false, :unique => true
  property :closed, Boolean, :default => false

  has n, :tickets, :constraint => :destroy

  before :destroy, :delete_tickets

  def delete_tickets
    tickets.each {|t| t.destroy}
  end

  def self.closed
    all(:closed => true)
  end

end
