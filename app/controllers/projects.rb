class Projects < Application
  # provides :xml, :yaml, :js
 
  before :ensure_authenticated, :exclude => [:index, :show, :overview]
  before :need_admin, :exclude => [:index, :show, :overview, :edit, :update]
  before :load_project, :only => [:edit, :update, :delete, :destroy]
  before :admin_project, :only => [:edit, :update]

  def index
    @projects = Project.all
    display @projects
  end

  def show(id)
    @project = Project.find(id)
    raise NotFound unless @project
    redirect resource(@project, :overview)
  end

  def overview(id)
    @project = Project.find(id)
    @events = @project.events.paginate(:order => 'created_at',
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
    @title = "edit #{@project.name}"
    display @project
  end

  def create(project)
    @project = Project.new_with_admin_member(project, session.user)
    if @project.save
      redirect resource(@project, :tickets), :message => {:notice => "Project was successfully created"}
    else
      message[:error] = "Project failed to be created"
      render :new
    end
  end

  def update(id, project)
    @project.user_creator = session.user
    if @project.update_attributes(project)
       redirect resource(@project, :tickets), :message => {:notice => "Project is update"}
    else
      display @project, :edit
    end
  end

  def delete(id)
    only_provides :html
    display @project
  end

  def destroy(id)
    if @project.destroy
      redirect resource(:projects), :message => {:notice => "Project #{@project.name} is delete"}
    else
      raise InternalServerError
    end
  end

  private

  def load_project
    @project = Project.find(params[:id])
  end

end # Projects
