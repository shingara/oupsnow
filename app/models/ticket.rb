class Ticket
  include DataMapper::Resource
  
  property :id, Serial
  property :title, String, :nullable => false
  property :description, Text

  belongs_to :project

end
