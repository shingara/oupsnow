class MilestonePart < Merb::PartController

  def index(project_id)
    @project = Project.get(project_id)
    @milestone = @project.current_milestone
    render
  end

end
