module Merb
  module GlobalHelpers

    def title_project
      ret = "Oupsnow" 
      ret += " : #{@project.name}" if @project && !@project.name.blank?
      ret
    end

    def title_header
      ret = "Oupsnow"
      ret += " - #{@project.name}" if @project && !@project.name.blank?
      ret += " : #{@title}" if @title
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

    def current_or_not(bool)
      bool ? "active" : ""
    end

    def overview_current
      current_or_not(@request.params[:controller] == 'projects' &&
                    @request.params[:action] == 'overview')
    end

    def milestone_current
      current_or_not(@request.params[:controller] == 'milestones')
    end

    def tickets_current
      current_or_not((@request.params[:controller] == 'tickets' && @request.params[:action] != 'new') ||
                     @request.params[:controller] == 'ticket_updates')
    end

    def projects_current
      current_or_not(@request.params[:controller] == 'projects' &&
                    @request.params[:action] != 'overview' &&
                    @request.params[:action] != 'edit' &&
                    @request.params[:action] != 'delete')
    end

    def tickets_new_current
      current_or_not(@request.params[:controller] == 'tickets' &&
                    @request.params[:action] == 'new')
    end

    def settings_current
      current_or_not( @request.params[:controller] =~ /settings\/\S+/ ||
                    (@request.params[:controller] == 'projects' && (@request.params[:action] == 'edit' || @request.params[:action] == 'delete')))
    end

    def textilized(text)
      text = "" if text.nil?
      RedCloth.new(text).to_html
    end

  end
end
