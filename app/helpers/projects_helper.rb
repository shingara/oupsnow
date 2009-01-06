module Merb
  module ProjectsHelper

    def sub_menu
      partial 'settings/sub_menu' if @request.params[:action] == "edit"
    end
  end
end # Merb
