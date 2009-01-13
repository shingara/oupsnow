class Projects < Application
  # provides :xml, :yaml, :js
 
  before :ensure_authenticated, :exclude => [:index, :show]
  before :need_admin, :exclude => [:index, :show]

  def index
    @projects = Project.all
    display @projects
  end

  def show(id)
    @project = Project.get(id)
    raise NotFound unless @project
    redirect resource(@project, :tickets)
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
    @project.members.build(:user => session.user, :function => Function.admin)
    if @project.save
      redirect resource(@project, :tickets), :message => {:notice => "Project was successfully created"}
    else
      message[:error] = "Project failed to be created"
      render :new
    end
  end

  def update(id, project)
    @project = Project.get(id)
    raise NotFound unless @project
    if @project.update_attributes(project)
       redirect resource(@project, :tickets)
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

  private

  def need_admin
    unless session.user.admin_on_one_project?
      raise Unauthenticated
    end
  end

end # Projects
