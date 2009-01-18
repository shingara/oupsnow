class Priority
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String

  has n, :tickets


end
