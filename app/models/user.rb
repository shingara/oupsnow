# This is a default user class used to activate merb-auth.  Feel free to change from a User to
# Some other class, or to remove it altogether.  If removed, merb-auth may not work by default.
#
# Don't forget that by default the salted_user mixin is used from merb-more
# You'll need to setup your db as per the salted_user mixin, and you'll need
# To use :password, and :password_confirmation when creating a user
#
# see merb/merb-auth/setup.rb to see how to disable the salted_user mixin
#
# You will need to setup your database and create a user.

class User

  include Mongoid::Document

  devise :authenticatable


  field :login
  alias :name :login
  field :email
  field :firstname
  field :lastname
  field :global_admin, :type => Boolean
  field :deleted_at, :type => DateTime

  validates_true_for :global_admin,
    :logic => lambda { allways_one_global_admin },
    :message => 'need a global admin'

  validates_presence_of :email
  validates_uniqueness_of :email
  validates_uniqueness_of :login

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
      User.all(:_id => user_ids.map{|i| ObjectId.to_mongo(i)}).each do |user|
        user.global_admin = true
        user.save
      end
      User.all(:_id => { '$nin' => user_ids.map{|i| ObjectId.to_mongo(i)} }).each do |user|
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
    if User.count == 0
      self.global_admin = true
      return true
    end
    unless self.global_admin
      if User.first(:conditions => {:_id => {'$ne' => self._id},
                                    :global_admin => true}) == nil
        return false
      end
    end
    return true
  end

end
