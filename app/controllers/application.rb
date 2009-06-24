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
    @project = Project.get(params[:project_id].to_i)
  end

  # attach to sidebar the part Milestone with project id define in argument
  def milestone_part(project_id)
    throw_content :sidebar, part(MilestonePart => :index, :project_id => project_id)
  end

  # Attach to sidebar the part Tags
  # There are several type to content tags. You need define it
  # Type available :
  #  * Projects
  def tag_cloud_part(type, type_id, project_id = nil)
    throw_content :sidebar, catch_content(:sidebar) + part(TagsPart => :index, :taggable => {:type => type, :type_id => type_id, :project_id => project_id})
  end

end
