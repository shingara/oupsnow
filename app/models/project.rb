class Project
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  property :description, Text

  validates_present :name
  validates_is_unique :name

end
