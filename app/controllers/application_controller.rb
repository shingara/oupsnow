class ApplicationController < ActionController::Base

  layout 'application'

  rescue_from Mongo::InvalidObjectID do
    return_404
  end

  rescue_from MongoMapper::DocumentNotFound do
    return_404
  end

  private

  def need_admin
    need_logged unless current_user.global_admin?
  end

  def admin_project
    need_logged unless current_user.global_admin? || current_user.admin?(@project)
  end

  ##
  # redirect to login form
  #
  def need_logged
    redirect_to new_user_session_url
  end

  def projects
    @project = Project.find!(params[:project_id])
  end

  # attach to sidebar the part Milestone with project id define in argument
  def milestone_part(project_id)
    logger.warn('need reimplement milestone')
    #throw_content :sidebar, part(MilestonePart => :index, :project_id => project_id)
  end

  def return_404
    render :status => 404, :file => 'public/404.html'
  end

  def return_401
    render :status => 401, :template => 'exceptions/unauthenticated'
  end

end
