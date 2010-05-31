require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe ProjectsController do

  render_views

  describe "resource(:projects)" do
    describe 'with anonymous user' do

      before do
        login_anonymous
      end
      describe "GET" do

        before(:each) do
          get :index
        end

        it "responds successfully" do
          response.should be_success
        end

        it "contains an empty list of projects" do
          response.should_not have_tag("h2")
        end

      end

      describe "GET" do


        before(:each) do
          2.of{ make_project }
          get :index
        end

        it "has a list of projects" do
          response.should have_tag("h2")
        end
      end
    end

    describe 'with admin user' do

      describe "a successful POST" do
        def post_request
          post :create, {:project => { :name => 'oupsnow' }}
        end

        before(:each) do
          login_admin
        end

        it "redirects to resource(:projects)" do
          post_request
          response.should redirect_to(project_tickets_url(Project.first(:conditions => {:name => 'oupsnow'})))
          flash[:notice].should == "Project was successfully created"
        end

        it 'should create one project' do
          lambda do
            post_request
          end.should change(Project, :count)
        end

      end
    end
  end

  describe "resource(@project) DELETE" do
    describe 'with admin user' do
      before(:each) do
        login_admin
        @project = make_project
        delete :destroy, :id => @project.id
      end

      it "should redirect to the index action" do
        response.should redirect_to(projects_url)
      end

      it 'should notice that project is delete' do
        flash[:notice].should == "Project #{@project.name} is delete"
      end

    end

    describe 'with user project admin' do
      before(:each) do
        user = login_request
        @project = make_project
        @project.add_member(user, Function.admin)
        delete :destroy, :id => @project.id
      end

      it "should define like not authorized" do
        response.should redirect_to(new_user_session_url)
      end

    end

    describe 'with base user' do
      before(:each) do
        user = login_request
        @project = make_project
        @project.add_member(user, function_not_admin)
        delete :destroy, :id => @project.id
      end

      it "should define like not authorized" do
        response.should redirect_to(new_user_session_url)
      end

    end
  end

  describe "resource(@project) DESTROY" do

    describe 'with admin user' do
      before(:each) do
        login_admin
        @project = make_project
        delete :destroy, :id => @project.id
      end

      it "should redirect to the index action" do
        response.should redirect_to(projects_url)
      end

      it 'should delete project' do
        Project.find_by_id(@project.id).should be_nil
      end

    end

    describe 'with user project admin' do
      before(:each) do
        user = login_request
        @project = make_project
        @project.add_member(user, Function.admin)
        delete :destroy, :id => @project.id
      end

      it "should define like not authorized" do
        response.should redirect_to(new_user_session_url)
      end

    end

    describe 'with base user' do
      before(:each) do
        user = login_request
        @project = make_project
        @project.add_member(user, function_not_admin)
        delete :destroy, :id => @project.id
      end

      it "should define like not authorized" do
        response.should redirect_to(new_user_session_url)
      end

    end
  end

  describe "resource(:projects, :new)" do
    describe 'with user logged' do
      before(:each) do
        login_request
        get :new
      end

      it "responds successfully" do
        response.should redirect_to(new_user_session_url)
      end
    end

    describe 'with admin user' do
      before(:each) do
        login_admin
        get :new
      end

      it "responds successfully" do
        response.should be_success
      end
    end
  end

  describe "resource(@project, :edit)" do
    describe 'with user logged' do
      before(:each) do
        login_request
        get :edit, :id => make_project.id
      end

      it "responds successfully" do
        response.should redirect_to(new_user_session_url)
      end
    end

    describe 'with admin logged' do
      before(:each) do
        login_admin
        get :edit, :id => make_project.id
      end

      it "responds successfully" do
        response.should be_success
      end
    end
  end

  describe "resource(@project)" do

    describe "GET" do
      before(:each) do
        @project = make_project
        get :show, :id => @project.id
      end

      it "responds successfully" do
        response.should redirect_to(overview_project_url(@project))
      end
    end

    describe "PUT" do
      describe 'with admin user' do
        before(:each) do
          login_admin
          @project = Project.first
          put :update, :id => @project.id,
            :project => {:id => @project.id, :name => 'update_name'}
        end

        it "redirect to the article show action" do
          response.should redirect_to(project_tickets_url(@project))
        end
      end
    end

  end


  describe 'it should be successful' , :shared => true do
    it 'should be successful' do
      response.should be_success
    end
  end

  describe 'resource(@project, :overview)' do
    def req
      @project = @project || make_project
      get :overview, :id => @project.id
    end

    describe 'with event desapear', :shared => true do
      before :each do
        login_anonymous
        ticket = Ticket.make
        @project = ticket.project
        ticket.write_create_event
        ticket.destroy
        req
      end

      it 'should be successfull with event deseapear' do
        response.should be_success
      end
    end

    describe 'with project unexist', :shared => true do
      it 'should render 404' do
        get :overview, :id => @project.id.to_s.succ
        response.code.should == '404'
        response.should render_template('public/404.html')
      end
    end

    describe 'anonymous user' do
      before :each do
        login_anonymous
        make_project unless Project.first
        @project = Project.first
        req
      end

      it_should_behave_like 'it should be successful'
      it_should_behave_like 'with event desapear'
    end

    describe 'login user' do
      before :each do
        login_request
        @project = Project.first || make_project
        req
      end

      it_should_behave_like 'it should be successful'
      it_should_behave_like 'with event desapear'
      it_should_behave_like 'with project unexist'
    end

    describe 'admin user' do
      before :each do
        login_admin
        @project = Project.first || make_project
        req
      end

      it_should_behave_like 'it should be successful'
      it_should_behave_like 'with event desapear'
    end
  end

  describe 'with admin user' do
    before do
      login_admin
    end

    describe 'delete page' do
      before do
        get :delete, :id => make_project.id
      end
      it { response.should be_success }
    end
  end
end
