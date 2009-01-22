class Application < Merb::Controller
  private

  def need_admin
    unless session.user.global_admin?
      raise Unauthenticated
    end
  end

  def admin_project
    unless session.user.admin?(@project)
      raise Unauthenticated
    end
  end

  def projects
    @project = Project.get(params[:project_id])
  end
end
