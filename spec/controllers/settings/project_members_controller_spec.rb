require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Settings::ProjectMembersController do

  integrate_views

  before :each do
    @project = make_project
    Function.make(:name => 'Developper')
  end

  describe 'like anonymous user' do
    before do
      login_anonymous
    end

  end

  describe 'like user logged and not project admin' do
    before do
      login_request
    end

    describe 'GET' do
      before do
        get :show, :project_id => @project.id, :id => @project.project_members.first.user_name
      end
      it {response.should redirect_to(new_user_session_url) }
    end

  end

  describe 'like user logged and project admin' do
    before do
      login_admin
    end

    describe 'GET' do
      before do
        get :show, :project_id => @project.id, :id => @project.project_members.first.user_name
      end

      it { response.should be_success }

    end

    describe 'index' do
      before do
        get :index, :project_id => @project.id
      end

      it { response.should be_success }

      it "contains a list of members" do
        response.should have_tag('table') do
          with_tag('tbody') do
            with_tag('tr') do
              with_tag('td')
            end
          end
        end
      end
    end

    describe 'POST' do
      before do
        @nb_members = Project.find(@project.id).project_members.size
        post :create, :project_id => @project.id,
          :project_members => {:user_id => User.make.id}
      end
      it { response.should redirect_to(project_project_members_url(@project)) }
      it { flash[:notice].should == "Member was successfully created" }
      it 'should add new project Members' do
        Project.find(@project.id).project_members.should have(@nb_members + 1).items
      end

    end

    describe '/new' do
      before do
        get :new, :project_id => @project.id
      end
      it {response.should be_success }
    end

    describe 'update_member' do
      before do
        @function = Function.make
        @project.project_members << ProjectMember.make
        @project.save!
        #put :update_all,
          #:project_id => @project.id,
          #:member_function => { @project.project_members.last.user_id => @function.id}
      end

      it {pending and response.should redirect_to(project_project_members_url(@project)) }
      it 'should change function of member' do
        pending
        Project.find(@project.id).project_members.last.function_name.should == @function.name
      end
      it {pending and flash[:notice].should == 'All members was updated'}
    end

  end

end


#describe 'update_all' do
  #describe 'like an admin' do
    #def made_request(member_function)
      #@response = request(resource(@project,
                                   #:settings,
                                   #:project_members,
                                   #:update_all),
                            #:method => "PUT",
                            #:params => {'member_function' => member_function})
    #end

    #before(:each) do
      #login_admin
      #@project = Project.first
      #@project.project_members.should_not have(3).items
      #@project.project_members << ProjectMember.make
      #@project.project_members << ProjectMember.new(:user => User.find_by_login('admin'),
                                                    #:function => Function.make)
      #@project.save!
      #@project.project_members.should have(3).items
    #end

    #it 'should redirect to project setting member without message because no change in update' do
      #member_function = {}
      #@project.project_members.each do |member|
        #member_function[member.id] = member.function_id
      #end
      #made_request(member_function)
      #@response.should redirect(url(:project_settings_project_members, @project),
                                #:message => {:notice => ""})
    #end

    #it 'should redirect to project setting member with message no change yourself because you change just youself' do
      #member_function = {}
      #@project.project_members.each do |member|
        #if member.id != User.find_by_login('admin').id
          #member_function[member.id] = member.function_id
        #else
          #member_function[member.id] = Function.make.id
        #end
      #end
      #made_request(member_function)
      #@response.should redirect(url(:project_settings_project_members, @project),
                                #:message => {:notice => ""})
    #end
  #end
#end
