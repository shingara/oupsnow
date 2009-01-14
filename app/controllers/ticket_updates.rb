class TicketUpdates < Application

  before :projects
  before :ticket
  before :ensure_authenticated
  before :admin_project 

  def edit(id)
    only_provides :html
    @ticket_update = TicketUpdate.get(id)
    raise NotFound unless @ticket_update
    display @ticket_update
  end

  def update(id, ticket_update)
    @ticket_update = TicketUpdate.get(id)
    @ticket_update.description = ticket_update[:description]
    if @ticket_update.save
      redirect resource(@project, @ticket)
    else
      display @ticket_update
    end
  end

  def ticket
    @ticket = Ticket.get(params[:ticket_id])
  end
  
end
