class ApplicationController < ActionController::Base

  helper :all
  layout 'application'

  private

  def need_admin
    # TODO integrate authlogic
    redirect_to login_url
    ##
    unless session.user.global_admin?
      redirect_to login_url
    end
  end

  def admin_project
    # TODO integrate authlogic
    redirect_to login_url
    ##
    unless session.user.global_admin? || session.user.admin?(@project)
      redirect_to login_url
    end
  end

  def projects
    @project = Project.get(params[:project_id])
  end

  # attach to sidebar the part Milestone with project id define in argument
  def milestone_part(project_id)
    logger.warn('need reimplement milestone')
    #throw_content :sidebar, part(MilestonePart => :index, :project_id => project_id)
  end

  # Attach to sidebar the part Tags
  # There are several type to content tags. You need define it
  # Type available :
  #  * Projects
  def tag_cloud_part(type, type_id, project_id = nil)
    tag_part(type, type_id, project_id)
  end

  def tag_part(type, type_id, project_id = nil)
    @cloud = {}
    #TODO: @cloud[:key] is usefull ?
    if type == 'Projects'
      @cloud[:project] = Project.find(type_id)
      @cloud[:tags] = @project.ticket_tag_counts
      @cloud[:key] = "projects/#{type_id}/#{ !@cloud[:project].events.empty? ? @cloud[:project].events.last(:order => 'updated_at DESC').created_at : @cloud[:project].created_at}"
    elsif type == 'Tickets'
      @cloud[:project] = Project.find(project_id)
      @cloud[:tags] = Ticket.find(type_id).tag_counts
      @cloud[:key] = "tickets/#{project_id}/#{ !@cloud[:project].events.empty? ? @cloud[:project].events.last(:order => 'updated_at DESC').created_at : @cloud[:project].created_at}"
    elsif type == 'Milestones'
      @cloud[:project] = Project.find(project_id)
      @cloud[:tags] = Milestone.find(type_id).tag_counts
      @cloud[:key] = "tickets/#{project_id}/#{ !@cloud[:project].events.empty? ? @cloud[:project].events.last(:order => 'updated_at DESC').created_at : @cloud[:project].created_at}"
    else
      raise NoMethodError
    end
  end

  def return_404
    #TODO: need render like 404
  end

end
