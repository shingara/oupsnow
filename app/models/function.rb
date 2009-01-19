class Function
  include DataMapper::Resource

  ADMIN = 'Admin'
  
  property :id, Serial
  property :name, String, :nullable => false, :unique => true

  has n, :members
  has n, :users, :through => :members
  has n, :projects, :through => :members

  before :destroy, :delete_all_members

  def delete_all_members
    members.each {|m| m.destroy}
  end

  def self.admin
    first(:name => ADMIN)
  end

  def admin?
    name == ADMIN
  end

end
