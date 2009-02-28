class Milestones < Application
  # provides :xml, :yaml, :js

  before :projects
  before :ensure_authenticated, :exclude => [:index, :show]
  before :admin_project, :exclude => [:index, :show]

  def index
    @milestones = Milestone.all(:project_id => @project.id, 
                                :order => [:expected_at])
    @title = "Milestones"
    display @milestones
  end

  def show(id)
    @milestone = Milestone.get(id)
    raise NotFound unless @milestone
    @title = "Milestone #{@milestone.name}"
    display @milestone
  end

  def new
    only_provides :html
    @milestone = Milestone.new(:project => @project)
    @title = "new milestone"
    display @milestone
  end

  def edit(id)
    only_provides :html
    @milestone = Milestone.get(id)
    raise NotFound unless @milestone
    @title = "edit milestone #{@milestone.name}"
    display @milestone
  end

  def create(milestone)
    @milestone = Milestone.new(milestone)
    @milestone.project = @project
    if @milestone.save
      @milestone.write_event_create(session.user)
      redirect resource(@project, @milestone), :message => {:notice => "Milestone was successfully created"}
    else
      message[:error] = "Milestone failed to be created"
      render :new
    end
  end

  def update(id, milestone)
    @milestone = Milestone.get(id)
    raise NotFound unless @milestone
    if @milestone.update_attributes(milestone)
       redirect resource(@project, @milestone)
    else
      display @milestone, :edit
    end
  end

  def destroy(id)
    @milestone = Milestone.get(id)
    raise NotFound unless @milestone
    if @milestone.destroy
      redirect resource(@project, :milestones)
    else
      raise InternalServerError
    end
  end

end # Milestones
