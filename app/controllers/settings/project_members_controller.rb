class Settings::ProjectMembersController < Settings::BaseController

  before_filter :projects
  before_filter :project_admin_authenticated

  def index
    @members = @project.project_members
    @title = "Members"
  end

  ##
  # show member of this project, the id is user_name
  def show
    # TODO: use detect instead find because find use by embeded proxy
    # update mongomapper to use that
    @member = @project.project_members.detect{|pm|
      pm.user_name == params[:id]
    }
    return return_404 unless @member
    @title = "member #{@member.user_name}"
  end

  def new
    @member = ProjectMember.new
    @title = "new member"
  end

  def create
    @member = ProjectMember.new(params[:project_member])
    @member.function_id = Function.first(:conditions => {:name => 'Developper'}).id
    @project.project_members << @member
    if @project.save!
      flash[:notice] = "Member was successfully created"
      redirect_to  project_project_members_url(@project)
    else
      flash[:error] = "Member failed to be created"
      render :new
    end
  end

  ##
  # Change all function of all member
  #
  # send a params in member_function. This params is a Hash
  # all keys are member.id and all values are function.id
  def update_all
    member_function = params[:member_function] || {}
    notice = ""
    # You can't change your own function
    member = @project.project_membership(current_user)
    if member &&
      member.function_id.to_s != member_function[member.id.to_s]
      notice += "You can't update your own function to become a non admin"
      member_function[member.id.to_s] = member.function_id.to_s
    end

    if @project.change_functions(member_function)
      notice += "All members was updated"
    else
      notice += "You can't have no admin in a project"
    end
    flash[:notice] = notice
    redirect_to project_project_members_url(@project)
  end

  private

  def project_admin_authenticated
    @project = Project.find(params[:project_id])
    need_logged and return unless current_user
    return true if current_user.global_admin?
    member = @project.project_members.detect{|pm| pm.user_id.to_s == current_user.id.to_s}
    need_logged and return unless member
    need_logged and return unless member.project_admin?
  end

end # Members
