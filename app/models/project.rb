class Project
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String

  validates_present :name
  validates_is_unique :name


end
