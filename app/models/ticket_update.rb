class TicketUpdate
  include DataMapper::Resource
  
  property :id, Serial
  property :properties_update, Yaml, :default => []
  property :description, Text
  property :created_at, DateTime

  belongs_to :ticket


end
