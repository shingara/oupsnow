require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe MilestonesController do

  render_views

  before do
    @project = make_project
  end

  describe 'logged user' do
    before do
      login_request
    end

    describe 'index' do
      describe 'without milestone' do
        before do
          get :index, :project_id => @project.id
        end

        it "responds successfully" do
          response.should be_success
        end

        it "contains a list of milestones" do
          response.should have_tag("ul")
        end
      end

      describe 'with milestone' do
        before do
          need_a_milestone
          get :index, :project_id => @project.id
        end

        it "responds successfully" do
          response.should be_success
        end

        it "contains a list of milestones" do
          response.should have_tag("ul") do
            with_tag('li')
          end
        end
      end
    end

    describe 'show' do
      before do
        need_a_milestone(@project)
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
        get :show, :project_id => @project.id,
          :id => @project.milestones.first.id
        response.should be_success
      end
    end
  end

  describe 'admin user' do
    before do
      login_admin
      @milestone = need_a_milestone(@project)
    end

    describe 'index' do
      before do
        get :index, :project_id => @project.id
      end
      it { response.should be_success }
    end

    describe 'create' do
      before do
        post :create, :project_id => @project.id,
                      :milestone => { :name => 'foo milestone' }
      end

      it "redirects to resource(:milestones)" do
        response.should redirect_to(project_milestone_url(@project, Milestone.first({:name => 'foo milestone', :project_id => @project.id})))
        flash[:notice].should == "Milestone was successfully created"
      end
    end

    describe 'destroy' do
      before do
        delete :destroy, :project_id => @project.id,
          :id => @milestone.id
      end

      it "should redirect to the index action" do
        response.should redirect_to(project_milestones_url(@project))
      end

      it 'should delete milestone' do
        Milestone.find(@milestone.id).should be_nil
      end
    end

    describe 'new' do
      before do
        get :new, :project_id => Project.first.id
      end

      it "responds successfully" do
        response.should be_success
      end
    end

    describe 'edit' do
      before do
        get :edit, :project_id => @project.id,
          :id => @project.milestones.first.id
      end

      it "responds successfully" do
        response.should be_success
      end
    end

    describe 'update' do
      before do
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
