class TicketUpdatesController < ApplicationController

  before_filter :projects
  before_filter :load_ticket
  before_filter :ensure_authenticated
  before_filter :admin_project 

  def edit
    @ticket_update = @ticket.get_update(params[:num])
    return return_404 unless @ticket_update
    @title = "edit update ticket #{@ticket.title}"
  end

  def update
    @ticket_update = @ticket.get_update(params[:num])
    @ticket_update.description = params[:ticket_update][:description]
    if @ticket.save
      redirect_to ticket_project(@project, @ticket)
    else
      render
    end
  end

  ##
  # load ticket with params in URL
  def load_ticket
    @ticket = Ticket.get_by_permalink(params[:project_id], 
                                      params[:ticket_permalink])
  end
  
end
