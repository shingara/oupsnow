class ProjectsController < ApplicationController

  before_filter :authenticate_user!, :except => [:index, :show, :overview]
  before_filter :need_admin, :except => [:index, :show, :overview, :edit, :update]
  before_filter :load_project, :only => [:edit, :update, :delete, :destroy]
  before_filter :admin_project, :only => [:edit, :update]

  def index
    @projects = Project.all
  end

  def show
    @project = Project.find(params[:id])
    return return_404 unless @project
    redirect_to overview_project_url(@project)
  end

  def overview
    @project = Project.find(params[:id])
    @events = @project.events.paginate(:order => 'created_at',
                                       :page => params[:page],
                                       :per_page => 20)
    return return_404 unless @project
  end

  def new
    @project = Project.new
    @title = "New Project"
  end

  def edit
    @title = "edit #{@project.name}"
  end

  def create
    @project = Project.new_with_admin_member(params[:project], current_user)
    if @project.save
      flash[:notice] = "Project was successfully created"
      redirect_to project_tickets_url(@project)
    else
      flash[:error] = "Project failed to be created"
      render :new
    end
  end

  def update
    @project.user_creator = current_user
    if @project.update_attributes(params[:project])
      flash[:notice] = 'Project is update'
      redirect_to project_tickets_url(@project)
    else
      render :edit
    end
  end

  ## see the destroy forms
  def delete
  end

  def destroy
    if @project.destroy
      flash[:notice] = "Project #{@project.name} is delete"
      redirect_to projects_url
    else
      raise InternalServerError
    end
  end

  private

  def load_project
    @project = Project.find(ObjectId.to_mongo(params[:id]))
  end

end # Projects
