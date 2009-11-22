module Settings::BaseHelper

  def sub_menu
    render(:partial => 'settings/sub_menu') if @project
  end

end
