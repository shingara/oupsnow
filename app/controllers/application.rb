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

  # attach to sidebar the part Milestone with project id define in argument
  def milestone_part(project_id)
    throw_content :sidebar, part(MilestonePart => :index, :project_id => project_id)
  end

  # Attach to sidebar the part Tags with project id define in argument
  def tag_cloud_part(project_id)
    throw_content :sidebar, catch_content(:sidebar) + part(TagsPart => :index, :project_id => @project.id)
  end

end
