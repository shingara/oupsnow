class MilestonesController < ApplicationController

  before_filter :projects
  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :admin_project, :except => [:index, :show]

  def index
    @current_milestone = @project.current_milestone
    @upcoming_milestones = @project.upcoming_milestones
    @no_date_milestones = @project.no_date_milestones
    @outdated_milestones = @project.outdated_milestones
  end

  def show
    @milestone = Milestone.find(params[:id])
    return return_404 unless @milestone
  end

  def new
    @milestone = Milestone.new(:project => @project)
    @title = "new milestone"
  end

  def edit
    @milestone = Milestone.find(params[:id])
    return return_404 unless @milestone
    @title = "edit milestone #{@milestone.name}"
  end

  def create
    milestone = params[:milestone]
    if milestone[:expected_at] && milestone[:expected_at].empty?
      milestone.delete(:expected_at)
    end
    @milestone = Milestone.new(milestone)
    @milestone.project = @project
    if @milestone.save
      @milestone.write_event_create(current_user)
      flash[:notice] = "Milestone was successfully created"
      redirect_to project_milestone_url(@project, @milestone)
    else
      flash[:error] = "Milestone failed to be created"
      render :new
    end
  end

  def update
    @milestone = Milestone.find(params[:id])
    return return_404 NotFound unless @milestone
    if @milestone.update_attributes(params[:milestone])
      redirect_to project_milestone_url(@project, @milestone)
    else
      render :edit
    end
  end

  def destroy
    @milestone = Milestone.find(params[:id])
    return return_404 unless @milestone
    if @milestone.destroy
      redirect_to project_milestones_url(@project)
    else
      raise InternalServerError
    end
  end

end # Milestones
