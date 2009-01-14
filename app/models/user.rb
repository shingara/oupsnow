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

  has n, :created_tickets, :class_name => "Ticket", :child_key => [:member_create_id]
  has n, :assigned_tickets, :class_name => "Ticket", :child_key => [:member_assigned_id]
  has n, :ticket_updates, :class_name => "TicketUpdate", :child_key => [:member_create_id]
  has n, :events

  before :destroy, :delete_member
  before :destroy, :delete_created_tickets
  before :destroy, :delete_assigned_tickets
  before :destroy, :delete_ticket_updates
  before :destroy, :delete_events

  def delete_member
    members.destroy!
  end

  def delete_created_tickets
    created_tickets.all.each {|t| t.destroy}
  end

  def delete_assigned_tickets
    assigned_tickets.all.each {|t| t.destroy}
  end

  def delete_ticket_updates
    ticket_updates.all.each {|t| t.destroy}
  end

  def delete_events
    events.destroy!
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
