require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe MilestonesController do

  integrate_views

  describe "resource(:milestones)" do
    describe "GET" do

      before(:each) do
        login_request
        get :index, :project_id => Project.first.id
      end

      it "responds successfully" do
        response.should be_success
      end

      it "contains a list of milestones" do
        response.should have_tag("ul")
      end

    end

    describe "GET" do
      before(:each) do
        login_request
        need_a_milestone
        get :index, :project_id => Project.first.id
      end

      it "has a list of milestones" do
        response.should have_tag("ul") do
          with_tag('li')
        end
      end
    end

    describe "a successful POST" do
      before(:each) do
        Milestone.collection.remove
        login_admin
        post :create, :project_id => Project.first,
                      :milestone => { :name => 'New Milestone' }
      end

      it "redirects to resource(:milestones)" do
        response.should redirect_to(project_milestone_url(Project.first, Milestone.first(:conditions => {:name => 'New Milestone'})))
        flash[:notice].should == "Milestone was successfully created"
      end

    end
  end

  describe "resource(@milestone)" do
    describe "a successful DELETE" do
      before(:each) do
        login_admin
        delete :destroy, :project_id => Project.first.id,
          :id => Project.first.milestones.first
      end

      it "should redirect to the index action" do
        response.should redirect_to(project_milestones_url(Project.first))
      end

    end
  end

  describe "resource(:milestones, :new)" do
    before(:each) do
      login_admin
      get :new, :project_id => Project.first
    end

    it "responds successfully" do
      response.should be_success
    end
  end

  describe "resource(@milestone, :edit)" do
    before(:each) do
      login_admin
      get :edit, :project_id => Project.first.id,
        :id => Project.first.milestones.first.id
    end

    it "responds successfully" do
      response.should be_success
    end
  end

  describe "resource(@milestone)" do

    describe "GET" do
      before(:each) do
        need_a_milestone
        login_request
      end

      it 'responses successfully even if ticket has no tag' do
        pr = Project.first
        ml = pr.milestones.first
        Ticket.make(:tag_list => '', :project => pr, :milestone => ml)
        get :show, :project_id => pr.id,
          :id => ml.id
        response.should be_success
      end

      it "responds successfully" do
        get :show, :project_id => Project.first.id,
          :id => Project.first.milestones.first.id
        response.should be_success
      end
    end

    describe "PUT" do
      before(:each) do
        login_admin
        @project = Project.first
        @milestone = @project.milestones.first
        put :update, :id => @milestone.id,
          :project_id => @project.id,
          :milestone => {:id => @milestone.id,
                          :name => 'HELLO'}
      end

      it "redirect to the article show action" do
        response.should redirect_to(project_milestone_url(@project, @milestone))
      end

      it "change name of milestone" do
        Milestone.find(@milestone.id).name.should == 'HELLO'
      end
    end

  end
end
