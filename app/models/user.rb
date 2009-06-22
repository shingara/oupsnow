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
  include DataMapper::Constraints
  
  property :id,     Serial
  property :login,  String, :nullable => false, :unique => true
  property :email,  String, :nullable => false, :unique => true, :format => :email_address
  property :firstname, String
  property :lastname, String
  property :global_admin, Boolean
  property :deleted_at, DateTime

  has n, :members
  has n, :functions, :through => :members, :constraint => :destroy
  has n, :projects, :through => :members, :constraint => :destroy

  has n, :created_tickets, :model => "Ticket", :child_key => [:member_create_id], :constraint => :destroy
  has n, :assigned_tickets, :model => "Ticket", :child_key => [:member_assigned_id], :constraint => :destroy
  has n, :ticket_updates, :model => "TicketUpdate", :child_key => [:member_create_id], :constraint => :destroy
  has n, :events, :constraint => :destroy

  validates_with_method :allways_one_global_admin

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
