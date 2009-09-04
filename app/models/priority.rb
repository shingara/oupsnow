class Priority

  include MongoMapper::Document
  
  key :name, String, :required => true, :unique => true

  before_destroy :only_without_ticket

  private

  ##
  # Destroy this priority if no association
  def only_without_ticket
    unless tickets.empty?
      raise DestroyException
    end
  end

end
