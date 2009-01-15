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

    def sub_menu
    end

  end
end
