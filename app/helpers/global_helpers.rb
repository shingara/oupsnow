module Merb
  module GlobalHelpers

    def title_project
      ret = "Oupsnow" 
      ret += " : #{@project.name}" if @project && @project.name == ""
      ret
    end

    def authenticated?
      session.user
    end

    def admin?(project)
      authenticated? && session.user.admin?(project)
    end

    def global_admin?
      authenticated? && session.user.global_admin?
    end

    def sub_menu
    end

    def actual_or_not(bool)
      bool ? "actual" : ""
    end

    def overview_actual
      actual_or_not(@request.params[:controller] == 'projects' &&
                    @request.params[:action] == 'overview')
    end

    def milestone_actual
      actual_or_not(@request.params[:controller] == 'milestones')
    end

    def tickets_actual
      actual_or_not((@request.params[:controller] == 'tickets' && @request.params[:action] != 'new') ||
                     @request.params[:controller] == 'ticket_updates')
    end

    def projects_actual
      actual_or_not(@request.params[:controller] == 'projects' &&
                    @request.params[:action] != 'overview' &&
                    @request.params[:action] != 'edit')
    end

    def tickets_new_actual
      actual_or_not(@request.params[:controller] == 'tickets' &&
                    @request.params[:action] == 'new')
    end

    def settings_actual
      actual_or_not( @request.params[:controller] =~ /settings\/\S+/ ||
                    (@request.params[:controller] == 'projects' && @request.params[:action] == 'edit'))
    end

  end
end
