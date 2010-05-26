class User

  include Mongoid::Document

  devise :database_authenticatable, :recoverable, :rememberable


  field :login, :type =>  String , :unique => true, :required => true
  validates_uniqueness_of :login
  validates_presence_of :login
  alias :name :login
  field :email,  :type => String
  field :firstname, :type =>  String
  field :lastname, :type => String
  field :global_admin, :type => Boolean
  field :deleted_at, :type => DateTime

  before_save :allways_one_global_admin
  validate :not_change_email

  validates_presence_of :email
  validates_uniqueness_of :email

  has_many_related :project_members

  ##
  # Check if this user is admin of this project
  #
  # @params[Project] project to test
  # @preturn[Boolean] if or not project_admin of this project
  def admin?(project)
    project.project_members.any? {|pm|
      pm.user_id == self._id && pm.project_admin?
    }
  end

  class << self

    ##
    # Get all user not in this project
    #
    # TODO: need some test
    #
    # @params[Project] project to test
    def not_in_project(project)
      all(:id => {'$nin' => project.project_members.map(&:user_id)})
    end

    ##
    # Change all user and define all user_id like global_admin
    # other become no global_admin
    #
    # @params[Array] All user global_admin
    def update_all_global_admin(user_ids)
      User.criteria.in(:_id => user_ids).each do |user|
        user.global_admin = true
        user.save
      end
      User.criteria.not_in(:_id => user_ids).each do |user|
        user.global_admin = false
        user.save
      end
    end

  end

  ##
  # Get all project where user is member
  #
  # TODO: need some test
  def projects
    Project.all(:conditions => {'project_members.user_id' => self.id})
  end

  def destroy
    deleted_at = Time.now
    save
  end

  private

  def allways_one_global_admin
    unless self.global_admin
      if User.where(:_id.ne => self._id, :global_admin => true).count < 1
        self.global_admin = true
      end
    end
  end

  def not_change_email
    errors.add(:email, 'should not be change') if !new_record? && email_changed?
  end

end
