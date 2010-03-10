class TicketsController < ApplicationController

  before_filter :projects
  before_filter :load_ticket, :only => [:show, :update, :edit_main_description,
    :update_main_description, :watch, :unwatch]
  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :admin_project, :only => [:edit_main_description,
                                    :update_main_description]
  before_filter :clean_params_ticket, :only => [:create, :update]

  # TODO change and report it on model because not params_accessible in Rails
  #params_accessible :ticket => [:title, :description, :tag_list, :member_assigned_id, :state_id, :priority_id, :milestone_id, :attachments]

  def index
    sort_by = params[:sort_by] || 'num'
    order = params[:order] || 'DESC'
    q = params[:q] || ''
    @tickets = Ticket.paginate_by_search(q, :project_id => @project.id,
                               :order => "#{sort_by} #{order}",
                               :page => params[:page],
                               :per_page => 20)
  end

  ##
  # Show a ticket
  #
  # TODO: need some test like test raise NotFound if no ticket found
  #
  # @params[String] project id
  # @params[String] permalink of this ticket (number of this ticket)
  def show
    return return_404 unless @ticket
    @ticket_change = @ticket.dup
    @ticket_change.description = ''
  end

  def new
    @ticket = Ticket.new(:project_id => params[:project_id])
    @title = "new ticket"
  end

  def edit_main_description
    @title = "Edit ticket description #{@ticket.title}"
  end

  def update_main_description
    @ticket.description = params[:ticket][:description]
    @ticket.title = params[:ticket][:title]
    if @ticket.save
      redirect_to project_ticket_url(@project, @ticket)
    else
      render :edit_main_description
    end
  end

  ##
  # Create the ticket
  # Only a member logged can create a ticket
  #
  def create
    @ticket = Ticket.new_by_params(params[:ticket], @project, current_user)
    if params[:commit] == 'Preview'
      @preview = true
      @ticket_new = true
      render :new
    else
      if @ticket.save
        @ticket.write_create_event
        flash[:notice] = "Ticket was successfully created"
        redirect_to project_ticket_url(@project, @ticket)
      else
        flash[:error] = "Ticket failed to be created"
        render :new
      end
    end
  end

  def update
    return return_404 unless @ticket
    @ticket_change = @ticket.dup
    # if value is blank, use default value
    if params[:commit] != 'Preview' &&
      if @ticket.generate_update(params[:ticket], current_user)
        redirect_to project_ticket_url(@project, @ticket)
      else
        render :show
      end
    else
      if params[:commit] == 'Preview'
        @preview_description = params[:ticket][:description]
      else
        flash[:error] = 'No new update added'
      end
      @ticket_change.attributes = params[:ticket]
      render :show
    end
  end

  def watch
    @ticket.watchers.build(:user => current_user)
    @ticket.save
    redirect_to project_ticket_url(@project, @ticket)
  end

  def unwatch
    @ticket.unwatch(current_user)
    @ticket.save
    redirect_to project_ticket_url(@project, @ticket)
  end

  private

  def load_ticket
    # The id of ticket is his num
    @ticket = Ticket.get_by_permalink(params[:project_id],
                                      params[:id])
    return return_404 unless @ticket
  end

  def clean_params_ticket
    params[:ticket].each { |k,v| params[:ticket][k] = nil if v.blank? }
  end

end # Tickets
