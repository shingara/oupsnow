class ProjectsController < ApplicationController
 
  before_filter :ensure_authenticated, :except => [:index, :show, :overview]
  before_filter :need_admin, :except => [:index, :show, :overview, :edit, :update]
  before_filter :load_project, :only => [:edit, :update, :delete, :destroy]
  before_filter :admin_project, :only => [:edit, :update]

  def index
    @projects = Project.all
  end

  def show(id)
    @project = Project.find(id)
    return return_404 unless @project
    redirect_to overview_project_url(@project)
  end

  def overview(id)
    @project = Project.find(id)
    @events = @project.events.paginate(:order => 'created_at',
                                       :page => params[:page],
                                       :per_page => 20)
    return return_404 unless @project
    milestone_part(@project.id)
    tag_cloud_part('Projects', @project.id)
    @title = "overview"
  end

  def new
    @project = Project.new
    @title = "New Project"
  end

  def edit(id)
    @title = "edit #{@project.name}"
  end

  def create(project)
    @project = Project.new_with_admin_member(project, session.user)
    if @project.save
      flash[:notice] = "Project was successfully created"
      redirect_to project_tickets_index(@project)
    else
      flash[:error] = "Project failed to be created"
      render :new
    end
  end

  def update(id, project)
    @project.user_creator = session.user
    if @project.update_attributes(project)
      flash[:notice] = 'Project is update'
      redirect_to project_tickets(@project)
    else
      render :edit
    end
  end

  def delete(id)
  end

  def destroy(id)
    if @project.destroy
      flash[:notice] = "Project #{@project.name} is delete"
      redirect_to projects_url
    else
      raise InternalServerError
    end
  end

  private

  def load_project
    @project = Project.find(params[:id])
  end

end # Projects
