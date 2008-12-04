class Ticket
  include DataMapper::Resource
  
  property :id, Serial
  property :title, String
  property :description, Text

  has 1, :project

end
