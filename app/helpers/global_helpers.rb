module Merb
  module GlobalHelpers

    def title_project
      ret = "Oupsnow" 
      ret += " : #{@project.name}" unless @project.nil? || @project == ""
      ret
    end

    def authenticated?
      session.user
    end

    def admin?(project)
      if authenticated? 
        session.user.admin?(project)
      else
        false
      end
    end

    def global_admin?
      if authenticated? 
        session.user.global_admin?
      else
        false
      end
    end

    def sub_menu
    end

    def overview_actual
      if @request.params[:controller] == 'projects' && @request.params[:action] == 'overview'
        "actual"
      else
        ""
      end
    end

    def milestone_actual
      if @request.params[:controller] == 'milestones'
        "actual"
      else
        ""
      end
    end

    def tickets_actual
      if @request.params[:controller] == 'tickets' && @request.params[:action] != 'new' ||
        @request.params[:controller] ==  'ticket_updates'
        "actual"
      else
        ""
      end
    end

    def projects_actual
      if @request.params[:controller] == 'projects' && @request.params[:action] != 'overview' && @request.params[:action] != 'edit'
        "actual"
      else
        ""
      end
    end

    def tickets_new_actual
      if @request.params[:controller] == 'tickets' && @request.params[:action] == 'new'
        "actual"
      else
        ""
      end
    end

    def settings_actual
      if @request.params[:controller] =~ /settings\/\S+/ ||
        @request.params[:controller] == 'projects' && @request.params[:action] == 'edit'
        "actual"
      else
        ""
      end
    end

  end
end
