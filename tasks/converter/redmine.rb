require 'tasks/converter/base.rb'
require 'tasks/converter/redmine/user.rb'
require 'tasks/converter/redmine/project.rb'
require 'tasks/converter/redmine/role.rb'
require 'tasks/converter/redmine/member.rb'
require 'tasks/converter/redmine/enumeration.rb'
require 'tasks/converter/redmine/tracker.rb'
require 'tasks/converter/redmine/category.rb'
require 'tasks/converter/redmine/issue.rb'
require 'tasks/converter/redmine/status.rb'


class RedmineConverter < BaseConverter

  def self.convert
    convert = new
    convert.import_users do |rd_user|
      User.new(:login => rd_user.login,
               :firstname => rd_user.firstname,
               :lastname => rd_user.lastname,
               :email => rd_user.mail,
               :global_admin => rd_user.admin)
    end

    convert.import_functions do |rd_function|
      Function.new(:name => rd_function.name,
                   :project_admin => rd_function.can_edit_project)
    end

    convert.import_projects do |rd_project|
      Project.new(:name => rd_project.name,
                  :description => rd_project.description)
    end

    # No member in project WARNING
    convert.import_members do |rd_member|
      Member.new(:user_id => User.first(:login => rd_member.user.login).id,
                 :project_id => Project.first(:name => rd_member.project.name).id,
                 :function_id => Function.first(:name => rd_member.role.name).id)
    end

    #State
    convert.import_states do |rd_state|
      State.new(:name => rd_state.name)
    end

    #Priority
    convert.import_priorities do |rd_priority|
      Priority.new(:name => rd_priority.name)
    end

    convert.import_tickets do |rd_ticket|
      p rd_ticket
      Ticket.new(:title => rd_ticket.subject,
                 :description => rd_ticket.description,
                 :created_at => rd_ticket.created_on,
                 :state_id => State.first(:name => rd_ticket.status.name).id,
                 :member_create_id => User.first(:login => rd_ticket.created_by.login).id,
                 :priority_id => Priority.first(:name => rd_ticket.priority.name).id,
                 :project_id => Project.first(:name => rd_ticket.project.name).id,
                 :member_assigned_id => rd_ticket.assigned_to ? User.first(:login => rd_ticket.assigned_to.login).id : nil,
                 :tag_list => [rd_ticket.tracker.name, 
                   (rd_ticket.category ? rd_ticket.category.name : "")])
    end
  end

  def old_users
    Redmine::User.all
  end

  def old_projects
    Redmine::Project.all
  end

  def old_functions
    Redmine::Role.all
  end

  def old_members
    Redmine::Member.all
  end

  def old_states
    Redmine::Status.all
  end

  def old_priorities
    Redmine::Enumeration.all(:opt => 'IPRI')
  end

  def old_tickets
    Redmine::Issue.all
  end

end
