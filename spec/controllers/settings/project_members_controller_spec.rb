require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Settings::ProjectMembersController do

  render_views

  before :each do
    @project = make_project
    Function.make(:name => 'developper', :project_admin => false)
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
          :project_member => {:user_id => User.make.id}
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
        @project.reload
        put :update_all,
          :project_id => @project.id,
          :member_function => { @project.project_members.last.id.to_s => @function.id.to_s}
      end

      it { response.should redirect_to(project_project_members_url(@project)) }
      it 'should change function of member' do
        Project.find(@project.id).project_members.last.function_name.should == @function.name
      end
      it {pending and flash[:notice].should == 'All members was updated'}
    end

  end

end
