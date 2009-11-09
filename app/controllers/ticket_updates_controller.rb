class TicketUpdatesController < ApplicationController

  before_filter :projects
  before_filter :load_ticket
  before_filter :authenticate_user!
  before_filter :admin_project
  before_filter :load_ticket_update

  def edit
    return return_404 unless @ticket_update
    @title = "edit update ticket #{@ticket.title}"
  end

  def update
    @ticket_update.description = params[:ticket_update][:description]
    if @ticket.save
      redirect_to project_ticket_url(@project, @ticket)
    else
      render :edit
    end
  end

  ##
  # load ticket with params in URL
  def load_ticket
    @ticket = Ticket.get_by_permalink(params[:project_id],
                                      params[:ticket_id])
    return_404 unless @ticket
  end

  def load_ticket_update
    @ticket_update = @ticket.get_update(params[:id])
    return_404 unless @ticket_update
  end

end
