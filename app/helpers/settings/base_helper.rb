module Settings::BaseHelper


  def active_or_not(bool)
    bool ? "active" : ""
  end

  def members_active
    active_or_not(params[:controller] == 'settings/project_members')
  end

  def project_edit_active
    active_or_not(params[:controller] == 'projects' &&
                  params[:action] == 'edit')
  end

  def project_delete_active
    active_or_not(params[:controller] == 'projects' &&
                  params[:action] == 'delete')
  end

end
