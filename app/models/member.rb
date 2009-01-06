class Member
  include DataMapper::Resource
  
  property :id, Serial

  belongs_to :function
  belongs_to :user
  belongs_to :project

  validates_present :function
  validates_present :user
  validates_present :project

  def admin?
    function.admin?
  end

end
