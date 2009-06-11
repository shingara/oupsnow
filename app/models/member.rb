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

  def project_admin?
    function.project_admin?
  end

  def user_name
    user.login
  end

  def self.change_functions(member_function)
    return true if member_function.empty?
    transaction do |txn|
      project = nil
      member_function.keys.each do |member_id|
        member = Member.get!(member_id.to_i)
        if project != member.project && !project.nil?
          txn.rollback
          return false
        end
        project = member.project
        member.function = Function.get!(member_function[member_id].to_i)
        member.save
      end
      project_have_admin = project.have_one_admin
      if project_have_admin.is_a?(Array) && !project_have_admin.first
        txn.rollback
        return false
      end
    end
    true
  end

end
