class Priority

  include MongoMapper::Document
  
  key :name, String #, :nullable => false, :unique => true

  before_destroy :only_without_ticket

  def only_without_ticket
    unless tickets.empty?
      raise DestroyException
    end
  end


end
