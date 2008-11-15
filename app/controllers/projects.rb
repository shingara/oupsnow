class Projects < Application
  # provides :xml, :yaml, :js

  def index
    @projects = Project.all
    display @projects
  end

  def show(id)
    @project = Project.get(id)
    raise NotFound unless @project
    display @project
  end

  def new
    only_provides :html
    @project = Project.new
    display @project
  end

  def edit(id)
    only_provides :html
    @project = Project.get(id)
    raise NotFound unless @project
    display @project
  end

  def create(project)
    @project = Project.new(project)
    if @project.save
      redirect resource(@project), :message => {:notice => "Project was successfully created"}
    else
      message[:error] = "Project failed to be created"
      render :new
    end
  end

  def update(id, project)
    @project = Project.get(id)
    raise NotFound unless @project
    if @project.update_attributes(project)
       redirect resource(@project)
    else
      display @project, :edit
    end
  end

  def destroy(id)
    @project = Project.get(id)
    raise NotFound unless @project
    if @project.destroy
      redirect resource(:projects)
    else
      raise InternalServerError
    end
  end

end # Projects
