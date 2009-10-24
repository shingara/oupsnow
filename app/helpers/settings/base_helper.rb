module Settings::BaseHelper

  def sub_menu
    partial 'settings/sub_menu'
  end

  def active_or_not(bool)
    bool ? "active" : ""
  end

  def members_active
    active_or_not(@request.params[:controller] == 'settings/project_members')
  end

  def project_edit_active
    active_or_not(@request.params[:controller] == 'projects' &&
                  @request.params[:action] == 'edit')
  end

  def project_delete_active
    active_or_not(@request.params[:controller] == 'projects' &&
                  @request.params[:action] == 'delete')
  end

end
