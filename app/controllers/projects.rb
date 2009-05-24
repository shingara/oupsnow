class Projects < Application
  # provides :xml, :yaml, :js
 
  before :ensure_authenticated, :exclude => [:index, :show, :overview]
  before :need_admin, :exclude => [:index, :show, :overview]

  def index
    @projects = Project.all
    display @projects
  end

  def show(id)
    @project = Project.get(id)
    raise NotFound unless @project
    redirect resource(@project, :overview)
  end

  def overview(id)
    @project = Project.get(id)
    @events = @project.events.paginate(:order => [:created_at.desc],
                                       :page => params[:page],
                                       :per_page => 20)
    raise NotFound unless @project
    milestone_part(@project.id)
    tag_cloud_part('Projects', @project.id)
    @title = "overview"
    display @events
  end

  def new
    only_provides :html
    @project = Project.new
    @title = "New Project"
    display @project
  end

  def edit(id)
    only_provides :html
    @project = Project.get(id)
    raise NotFound unless @project
    @title = "edit #{@project.name}"
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

  def delete(id)
    only_provides :html
    @project = Project.get(id)
    display @project
  end

  def destroy(id)
    @project = Project.get(id)
    raise NotFound unless @project
    if @project.destroy
      redirect resource(:projects), :message => {:notice => "Project #{@project.name} is delete"}
    else
      raise InternalServerError
    end
  end

  private


end # Projects
