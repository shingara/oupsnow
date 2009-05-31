class Function
  include DataMapper::Resource

  ADMIN = 'Admin'

  property :id, Serial
  property :name, String, :nullable => false, :unique => true
  property :project_admin, Boolean

  has n, :members
  has n, :users, :through => :members, :constraint => :destroy
  has n, :projects, :through => :members, :constraint => :destroy

  before :destroy, :delete_all_members

  def delete_all_members
    members.each {|m| m.destroy}
  end

  def self.admin
    Function.first(:project_admin => true)
  end

  def self.not_admin
    Function.first(:project_admin => false)
  end

end
