module Merb
  module Settings
    module GlobalHelper

      def sub_menu
        partial 'settings/sub_menu'
      end
      
      def active_or_not(bool)
        bool ? "active" : ""
      end

      def members_active
        active_or_not(@request.params[:controller] == 'settings/members')
      end

      def project_edit_active
        active_or_not(@request.params[:controller] == 'projects' &&
                     @request.params[:action] == 'edit')
      end
  
    end
  end # Settings
end # Merb
