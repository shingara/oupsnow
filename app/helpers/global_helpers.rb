module Merb
  module GlobalHelpers

    def title_project
      ret = "Oupsnow" 
      ret += " : #{@project.name}" unless @project.nil? || @project == ""
      ret
    end

  end
end
