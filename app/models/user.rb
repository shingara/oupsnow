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

  include DataMapper::Resource
  
  property :id,     Serial
  property :login,  String, :nullable => false, :unique => true
  property :email,  String, :nullable => false, :format => :email_address

  has n, :members
  has n, :functions, :through => :members
  has n, :projects, :through => :members

  before :destroy, :delete_member

  def delete_member
    members.destroy!
  end

  def admin?(project)
    members.first(:project_id => project.id).admin?
  end

  def admin_on_one_project?
    !members.first(:function_id => Function.admin.id).nil?
  end

  def self.not_in_project(project)
    all(:id.not => project.users.map{|u| u.id})
  end

end
