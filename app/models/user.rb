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
require 'lib/mongomapper_salted_user.rb'

class User

  include MongoMapper::Document
  extend Merb::Authentication::Mixins::SaltedUser::MongoMapperClassMethods
  
  key :login,  String
  key :email,  String
  key :firstname, String
  key :lastname, String
  key :global_admin, Boolean
  key :deleted_at, DateTime

  validates_true_for :global_admin, :logic => lambda { allways_one_global_admin },
    :message => 'need a global admin'

  def admin?(project)
    m = members.first(:project_id => project.id)
    m && m.project_admin?
  end

  def self.not_in_project(project)
    all(:id.not => project.users.map{|u| u.id})
  end

  def destroy
    deleted_at = Time.now
    save
  end

  private

  def allways_one_global_admin
    unless self.global_admin
      if User.first(:id.not => self.id, :global_admin => true) == nil
        return [false, 'You need one global admin']
      end
    end
    return true
  end

end
