module Settings
  class ProjectMembers < Application
    # provides :xml, :yaml, :js
    
    before :projects
    before :project_admin_authenticated
  
    def index(project_id)
      @members = @project.project_members
      @title = "Members"
      display @members
    end
  
    def show(user_name)
      @member = @project.project_members.find{|pm| pm.user_name == user_name}
      raise NotFound unless @member
      @title = "member #{@member.user_name}"
      display @member
    end
  
    def new
      only_provides :html
      @member = ProjectMember.new
      @title = "new member"
      display @member
    end
  
    def create(project_member)
      @member = ProjectMember.new(project_member)
      @member.function_id = Function.first(:conditions => {:name => 'Developper'}).id
      @project.project_members << @member
      if @project.save!
        redirect url(:project_settings_project_members, @project), :message => {:notice => "Member was successfully created"}
      else
        message[:error] = "Member failed to be created"
        render :new
      end
    end

    def update_all(member_function={})
      notice = ""
      # You can't change your own function
      if @project.has_member?(session.user)
        member = @project.members.first(:user_id => session.user.id)
        unless member.function.id.to_s == member_function[member.id.to_s]
          notice += "You can't update your own function to become a non admin"
          member_function[member.id.to_s] = member.function.id.to_s
        end
      end

      if Member.change_functions(member_function)
        notice += "All members was updated"
      else
        notice += "You can't have no admin in a project"
      end
      redirect url(:project_settings_members, @project), :message => {:notice => notice}
    end
  
    private

    def project_admin_authenticated
      @project = Project.get(params[:project_id])
      raise Unauthenticated unless session.user
      return true if session.user.global_admin?
      member = @project.project_members.find{|pm| pm.user_id == session.user.id}
      raise Unauthenticated if member.nil?
      raise Unauthenticated unless member.project_admin?
    end

  end # Members
end # Settings
