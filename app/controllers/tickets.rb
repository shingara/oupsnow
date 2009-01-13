class Tickets < Application
  # provides :xml, :yaml, :js
  
  before :projects
  before :ensure_authenticated, :exclude => [:index, :show]

  params_accessible :ticket => [:title, :description, :tag_list, :member_assigned_id, :state_id]

  def projects
    @project = Project.get(params[:project_id])
  end

  def index
    @tickets = Ticket.all :project_id => @project.id
    display @tickets
  end

  def show(id)
    @ticket = Ticket.get(params[:id])
    raise NotFound unless @ticket
    display @ticket
  end

  def new(project_id)
    only_provides :html
    @ticket = Ticket.new(:project_id => project_id)
    display @ticket
  end

  def edit(id)
    only_provides :html
    @ticket = Ticket.get(id)
    raise NotFound unless @ticket
    display @ticket
  end

  def create(ticket)
    @ticket = Ticket.new(ticket)
    @ticket.project_id = @project.id
    @ticket.created_by = session.user
    if @ticket.save
      redirect resource(@project, @ticket), :message => {:notice => "Ticket was successfully created"}
    else
      message[:error] = "Ticket failed to be created"
      render :new
    end
  end

  def update(id, ticket)
    @ticket = Ticket.get(id)
    raise NotFound unless @ticket
    if @ticket.generate_update(ticket)
      redirect resource(@project, @ticket)
    else
      display @ticket, :show
    end
  end

end # Tickets
