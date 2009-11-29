module ProjectsHelper

  def time_overview(date)
    if @previous_date.nil? || date.day != @previous_date.day
      @previous_date = date
      return "<span class='day'>#{date.strftime('%B %d')}</span>"
    else
      return "<span class='time'>#{date.strftime('%H:%M')}</span>"
    end
  end
end
