class Tickets < Application
  # provides :xml, :yaml, :js

  def index
    @tickets = Ticket.all
    display @tickets
  end

  def show(id)
    @ticket = Ticket.get(id)
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
    if @ticket.save
      redirect resource(@ticket), :message => {:notice => "Ticket was successfully created"}
    else
      message[:error] = "Ticket failed to be created"
      render :new
    end
  end

  def update(id, ticket)
    @ticket = Ticket.get(id)
    raise NotFound unless @ticket
    if @ticket.update_attributes(ticket)
       redirect resource(@ticket)
    else
      display @ticket, :edit
    end
  end

  def destroy(id)
    @ticket = Ticket.get(id)
    raise NotFound unless @ticket
    if @ticket.destroy
      redirect resource(:tickets)
    else
      raise InternalServerError
    end
  end

end # Tickets
