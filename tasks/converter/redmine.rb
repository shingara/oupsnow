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
require 'tasks/converter/redmine/version.rb'
require 'tasks/converter/redmine/journal.rb'
require 'tasks/converter/redmine/journal_detail.rb'


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
      State.new(:name => rd_state.name,
               :closed => rd_state.is_closed)
    end

    #Priority
    convert.import_priorities do |rd_priority|
      Priority.new(:name => rd_priority.name)
    end

    #TODO: integrate event
    convert.import_milestones do |rd_milestone|
      Milestone.new(:name => rd_milestone.name,
                    :description => rd_milestone.description,
                    :expected_at => rd_milestone.effective_date,
                    :project_id => Project.first(:name => Redmine::Project.get(rd_milestone.project_id).name).id)
    end

    #TODO: integrate event (WARNING event create in after hook)
    tickets = convert.import_tickets do |rd_ticket|
      project_ticket = Project.first(:name => rd_ticket.project.name)
      Ticket.new(:title => rd_ticket.subject,
                 :description => rd_ticket.description,
                 :created_at => rd_ticket.created_on,
                 :state_id => State.first(:name => rd_ticket.status.name).id,
                 :member_create_id => User.first(:login => rd_ticket.created_by.login).id,
                 :priority_id => Priority.first(:name => rd_ticket.priority.name).id,
                 :project_id => project_ticket.id,
                 :member_assigned_id => rd_ticket.assigned_to ? User.first(:login => rd_ticket.assigned_to.login).id : nil,
                 :milestone_id => rd_ticket.version ? project_ticket.milestones.first(:name => rd_ticket.version.name).id : nil,
                 :tag_list => [rd_ticket.tracker.name, 
                   (rd_ticket.category ? rd_ticket.category.name : "")].join(','))
    end

    #TODO: integrate event
    convert.import_ticket_updates do |rd_ticket_update_old|
      TicketUpdate.new (:ticket_id => tickets[rd_ticket_update_old.journalized_id].id,
                        :member_create_id => User.first(:login => rd_ticket_update_old.user.login).id,
                        :created_at => rd_ticket_update_old.created_on,
                        :description => rd_ticket_update_old.notes,
                        :properties_update => rd_ticket_update_old.properties_update)
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

  def old_milestones
    Redmine::Version.all
  end

  def old_tickets
    Redmine::Issue.all
  end

  def old_ticket_updates
    Redmine::Journal.all(:journalized_type => 'Issue')
  end

end
