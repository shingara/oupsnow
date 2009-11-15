module Admin::BaseHelper

  def sub_menu
    render :partial => 'admin/sub_menu'
  end

  def active_or_not(bool)
    bool ? "active" : ""
  end

  def functions_active
    active_or_not(params[:controller] == 'admin/functions')
  end

  def priorities_active
    active_or_not(params[:controller] == 'admin/priorities')
  end

  def states_active
    active_or_not(params[:controller] == 'admin/states')
  end

  def users_active
    active_or_not(params[:controller] == 'admin/users')
  end

end
