class Member
  include DataMapper::Resource
  
  property :id, Serial

  belongs_to :function
  belongs_to :user
  belongs_to :project

  validates_present :function
  validates_present :user
  validates_present :project

  validates_is_unique :user_id, :scope => :project_id,
        :message => "This user is already member of this project"

  def admin?
    function.admin?
  end

end
