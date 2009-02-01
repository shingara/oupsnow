class State
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :nullable => false, :unique => true
  property :closed, Boolean, :default => false

  has n, :tickets

  before :destroy, :delete_tickets

  def delete_tickets
    tickets.each {|t| t.destroy}
  end

end
