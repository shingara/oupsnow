class TicketsController < ApplicationController
  
  before_filter :projects
  before_filter :load_ticket, :only => [:show, :update, :edit_main_description, 
    :update_main_description]
  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :admin_project, :only => [:edit_main_description, 
                                    :update_main_description]

  # TODO change and report it on model because not params_accessible in Rails
  #params_accessible :ticket => [:title, :description, :tag_list, :member_assigned_id, :state_id, :priority_id, :milestone_id, :attachments]

  def index
    sort_by = params[:sort_by] || 'id'
    order = params[:order] || 'DESC'
    q = params[:q] || ''
    @tickets = Ticket.paginate_by_search(q, :project_id => @project.id,
                               :order => "#{sort_by} #{order}",
                               :page => params[:page],
                               :per_page => 20)
    milestone_part(@project.id)
    tag_cloud_part('Projects', @project.id)
    @title = "Tickets"
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
    return return_404 unless @ticket
    @title = "Edit ticket description #{@ticket.title}"
    display @ticket
  end

  def update_main_description
    @ticket.description = params[:ticket][:description]
    @ticket.title = params[:ticket][:title]
    if @ticket.save
      redirect ticket_project_url(@project, @ticket)
    else
      render :edit_main_description
    end
  end

  def create
    @ticket = Ticket.new(params[:ticket])
    @ticket.project_id = @project.id
    @ticket.user_creator = session.user
    if params[:submit] == 'Preview'
      @preview = true
      @ticket_new = true
      render :new
    else
      if @ticket.save
        @ticket.write_create_event
        flash[:notice] = "Ticket was successfully created"
        redirect_to project_ticket(@project, @ticket)
      else
        falsh[:error] = "Ticket failed to be created"
        render :new
      end
    end
  end

  def update
    return return_404 unless @ticket
    @ticket_change = @ticket.dup
    if params[:submit] != 'Preview' && 
      @ticket.generate_update(params[:ticket], session.user)
      redirect_to project_ticket(@project, @ticket)
    else
      if params[:submit] == 'Preview'
        @preview_description = params[:ticket][:description]
      else
        flash[:error] = 'No new update added'
      end
      [:title, :description, :user_assigned_id, :state_id, :priority_id, :milestone_id, :tag_list].each do |u|
        @ticket_change.send("#{u}=", params[:ticket][u])
      end
      render :show
    end
  end

  private

  def load_ticket
    @ticket = Ticket.get_by_permalink(params[:project_id], 
                                      params[:ticket_permalink])
    return return_404 unless @ticket
  end

end # Tickets
