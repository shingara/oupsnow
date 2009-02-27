class TagsPart < Merb::PartController

  def index(project_id)
    @project = Project.get(project_id)
    render
  end

end
