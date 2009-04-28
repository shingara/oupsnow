class State
  include DataMapper::Resource
  include DataMapper::Constraints
  
  property :id, Serial
  property :name, String, :nullable => false, :unique => true
  property :closed, Boolean, :default => false

  has n, :tickets, :constraint => :destroy

  def self.closed
    all(:closed => true)
  end

end
