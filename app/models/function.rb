class Function
  include DataMapper::Resource

  ADMIN = 'Admin'
  
  property :id, Serial
  property :name, String, :nullable => false, :unique => true

  has n, :members
  has n, :users, :through => :members
  has n, :projects, :through => :members

  def self.admin
    first(:name => ADMIN)
  end

  def admin?
    name == ADMIN
  end

end
