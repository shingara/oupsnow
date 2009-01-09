class State
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :nullable => false


end
