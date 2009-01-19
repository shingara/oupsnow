class Priority
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :nullable => false, :unique => true

  has n, :tickets

  before :destroy, :only_without_ticket

  def only_without_ticket
    unless tickets.empty?
      raise DestroyException
    end
  end


end
