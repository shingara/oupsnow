module Merb
  module ProjectsHelper

    include Settings::GlobalHelper

    def sub_menu
      partial 'settings/sub_menu' if @request.params[:action] == "edit"
    end

    def time_overview(date)
      if @previous_date.nil? || date.day != @previous_date.day
        @previous_date = date
        return "<span>#{date.strftime('%B %d')}</span>"
      else
        return "<span>#{date.strftime('%H:%M')}</span>"
      end
    end
  end
end # Merb
