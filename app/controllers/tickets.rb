class Tickets < Application
  # provides :xml, :yaml, :js
  
  before :projects
  before :ensure_authenticated, :exclude => [:index, :show]
  before :admin_project, :only => [:edit_main_description, 
                                    :update_main_description]

  params_accessible :ticket => [:title, :description, :tag_list, :member_assigned_id, :state_id, :priority_id, :milestone_id, :attachments]

  def index(sort_by='_id', order='DESC', q='')
    @tickets = Ticket.paginate_by_search(q, :project_id => @project.id,
                               :order => "#{sort_by} #{order}",
                               :page => params[:page],
                               :per_page => 20)
    milestone_part(@project.id)
    tag_cloud_part('Projects', @project.id)
    @title = "Tickets"
    display @tickets
  end

  ##
  # Show a ticket
  #
  # TODO: need some test like test raise NotFound if no ticket found
  # 
  # @params[String] project id
  # @params[String] permalink of this ticket (number of this ticket)
  def show(project_id, ticket_permalink)
    @ticket = Ticket.get_by_permalink(project_id, ticket_permalink)
    raise NotFound unless @ticket
    @ticket_update = @ticket.dup
    @ticket_update.description = ''
    @title = "ticket #{@ticket.title}"
    tag_cloud_part('Tickets', @ticket.id, @project.id)
    display @ticket
  end

  def new(project_id)
    only_provides :html
    @ticket = Ticket.new(:project_id => project_id)
    #@ticket.attachments.build
    @title = "new ticket"
    display @ticket
  end

  def edit_main_description(project_id, ticket_permalink)
    only_provides :html
    @ticket = Ticket.get_by_permalink(project_id, ticket_permalink)
    raise NotFound unless @ticket
    @title = "Edit ticket description #{@ticket.title}"
    display @ticket
  end

  def update_main_description(project_id, ticket_permalink, ticket)
    @ticket = Ticket.get_by_permalink(project_id, ticket_permalink)
    raise NotFound unless @ticket
    @ticket.description = ticket[:description]
    @ticket.title = ticket[:title]
    if @ticket.save
      redirect resource(@project, @ticket)
    else
      render :edit_main_description
    end
  end

  def create(ticket)
    @ticket = Ticket.new(ticket)
    @ticket.project_id = @project.id
    @ticket.user_creator = session.user
    if params[:submit] == 'Preview'
      @preview = true
      @ticket_new = true
      render :new
    else
      if @ticket.save
        @ticket.write_create_event
        redirect resource(@project, @ticket), :message => {:notice => "Ticket was successfully created"}
      else
        message[:error] = "Ticket failed to be created"
        render :new
      end
    end
  end

  def update(project_id, ticket_permalink, ticket)
    @ticket = Ticket.get_by_permalink(project_id, ticket_permalink)
    raise NotFound unless @ticket
    if params[:submit] == 'Preview'
      @preview_description = ticket[:description]
      @ticket_update = @ticket.dup
      [:title, :description, :user_assigned_id, :state_id, :priority_id, :milestone_id, :tag_list].each do |u|
        @ticket_update.send("#{u}=", ticket[u])
      end
      render :show
    else
      if @ticket.generate_update(ticket, session.user)
        redirect resource(@project, @ticket)
      else
        display @ticket, :show
      end
    end
  end

end # Tickets
