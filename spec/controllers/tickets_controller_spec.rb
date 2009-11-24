require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe TicketsController do

  integrate_views

  before :each do
    @project = make_project
    State.make
  end

  describe 'success #index', :shared => true do

    integrate_views

    before do
      get :index, :project_id => @project.id
    end

    it { response.should be_success }
    it { response.should have_tag('ul') }
  end
  describe 'success show', :shared => true do
    before do
      @ticket = make_ticket(:project => @project)
      make_ticket_update(@ticket, {:user_assigned_id => nil})
      @ticket = Ticket.find(@ticket.id)
      make_ticket_update(@ticket, {:user_assigned_id => @project.project_members.first.user_id,
                         :project => @project})
      @ticket = Ticket.find(@ticket.id)
    end

    def success_request
      get :show, :project_id => @project.id, :id => @ticket.num
    end
    def failed_request
      get :show, :project_id => @project.id, :id => @ticket.id
    end
    it 'should success with a success request' do
      success_request
      response.should be_success
    end
    it "should render 404 if ticket doens't exist" do
      failed_request
      response.code.should == '404'
      response.should render_template('public/404.html')
    end
  end

  describe 'success', :shared => true do
    before { req }
    it { response.should be_success }
  end

  describe 'create ticket', :shared => true do
    describe 'valid creation of ticket' do
      before do
        @nb_tickets = @project.tickets.size
        post :create, :project_id => @project.id,
          :ticket => ({ :title => 'a new ticket',
                      :state_id => State.first.id})
        @project = Project.find(@project.id)
      end
      it 'should create ticket' do
        @project.tickets.should_not be_empty
      end

      it "redirects to resource(Project.first, :tickets)" do
        response.should redirect_to(project_ticket_url(@project, @project.tickets.last(:order => 'created_at ASC')))
      end

      it 'should have a notice' do
        flash[:notice].should == "Ticket was successfully created"
      end

      it 'project should have one ticket' do
        @project.tickets.should have(@nb_tickets + 1).items
      end
    end

    describe 'failed creation of ticket' do
      before do
        @nb_tickets = @project.tickets.size
        post :create, :project_id => @project.id,
          :ticket => ({ :title => '', # We need a title
                      :state_id => State.first.id})
        @project = Project.find(@project.id)
      end
      it { response.should render_template(:new) }
      it 'should no creation of ticket' do
        @project.tickets.size.should == @nb_tickets
      end
      it { flash[:error].should == 'Ticket failed to be created' }
    end
  end

  describe 'not access', :shared => true do
    it 'should not access' do
      req
      response.should redirect_to(new_user_session_url(:unauthenticated=>true))
    end
  end

  describe 'update ticket', :shared => true do
    before do
      @ticket = make_ticket(:project => @project)
    end
    describe 'update success' do
      before do
        put :update, :id => @ticket.num,
          :project_id => @project.id,
          :ticket => {:description => 'new comment',
            :state_id => State.first.id}
      end
      it { response.should redirect_to(project_ticket_url(@project, @ticket)) }
      it { Ticket.find(@ticket.id).ticket_updates.should_not be_empty }
      it { Ticket.find(@ticket.id).ticket_updates.first.description.should == 'new comment' }
    end
  end

  describe 'with a anonymous' do
    before do
      login_anonymous
    end
    describe '#index' do
      it_should_behave_like 'success #index'
    end
    describe 'show' do
      it_should_behave_like 'success show'
    end

    describe '/new' do
      def req
        get :new, :project_id => @project.id
      end
      it_should_behave_like 'not access'
    end

    describe '#post' do
      def req
        post :create, :project_id => @project.id,
          :ticket => ({ :title => 'a new ticket',
                      :state_id => State.first.id})
      end
      it_should_behave_like 'not access'
      it 'should not add tickets to project' do
        @project.tickets.should be_empty
      end
    end
    describe '#update' do
      def req
        put :update, :id => @ticket.num,
          :project_id => @project.id,
          :ticket => {:description => 'new comment',
            :state_id => State.first.id}
      end
      before do
        @ticket = make_ticket(:project => @project)
      end
      it_should_behave_like 'not access'
      it 'should not add ticket updates' do
        Ticket.find(@ticket.id).ticket_updates.should be_empty
      end
    end
    describe '/edit_main_description' do
      def req
        get :edit_main_description, :project_id => @project.id,
          :id => make_ticket(:project => @project).num
      end
      it_should_behave_like 'not access'
    end
    describe 'Update main description' do
      def req
        ticket = make_ticket(:project => @project)
        put :update_main_description, :project_id => @project.id,
          :id => ticket.num,
          :ticket => {:description => 'yahoo',
            :title => ticket.title}
      end
      it_should_behave_like 'not access'
    end
  end

  describe 'with a user logged not admin project' do

    before do
      login_request
    end

    describe '#index' do
      it_should_behave_like 'success #index'
    end
    describe 'show' do
      it_should_behave_like 'success show'
    end
    describe 'POST' do
      it_should_behave_like 'create ticket'
    end
    describe '/new' do
      def req
        get :new, :project_id => @project.id
      end
      it_should_behave_like 'success'
    end
    describe '/edit_main_description' do
      before do
        get :edit_main_description, :project_id => @project.id,
          :id => make_ticket(:project => @project).num
      end
      it { response.should redirect_to(new_user_session_url) }
    end
    describe 'Update main description' do
      before do
        ticket = make_ticket(:project => @project)
        put :update_main_description, :project_id => @project.id,
          :id => ticket.num,
          :ticket => {:description => 'yahoo',
            :title => ticket.title}
      end
      it { response.should redirect_to(new_user_session_url) }
    end
    describe 'PUT' do
      it_should_behave_like 'update ticket'
    end
  end

  describe 'with a user logged and admin project' do
    before do
      login_admin
    end
    describe '#index' do
      it_should_behave_like 'success #index'
    end
    describe 'show' do
      it_should_behave_like 'success show'
    end
    describe 'POST' do
      it_should_behave_like 'create ticket'
    end
    describe '/new' do
      def req
        get :new, :project_id => @project.id
      end
      it_should_behave_like 'success'
    end
    describe '/edit_main_description' do
      describe 'with good num ticket' do
        before do
          get :edit_main_description, :project_id => @project.id,
            :id => make_ticket(:project => @project).num
        end
        it { response.should be_success }
        it { response.should render_template(:edit_main_description) }
      end

      describe 'with bad num ticket' do
        before do
          get :edit_main_description, :project_id => @project.id,
            :id => make_ticket(:project => @project).id
        end
        it { response.code.should == '404'  }
        it { response.should render_template('public/404.html') }
      end
    end
    describe 'update main description' do
      describe 'update successful' do
        before do
          @ticket = make_ticket(:project => @project)
          put :update_main_description, :project_id => @project.id,
            :id => @ticket.num,
            :ticket => {:description => 'yahoo',
              :title => @ticket.title}
        end
        it { response.should redirect_to(project_ticket_url(@project, @ticket)) }
        it { Ticket.find(@ticket.id).description.should == 'yahoo' }
      end
      describe 'update failed' do
        before do
          @ticket = make_ticket(:project => @project)
          put :update_main_description, :project_id => @project.id,
            :id => @ticket.num,
            :ticket => {:description => 'yahoo',
              :title => ''}
        end
        it { response.should render_template(:edit_main_description) }
        it { Ticket.find(@ticket.id).description.should_not == 'yahoo' }
      end
      describe 'not exist' do
        before do
          @ticket = make_ticket(:project => @project)
          put :update_main_description, :project_id => @project.id,
            :id => @ticket.id,
            :ticket => {:description => 'yahoo',
              :title => ''}
        end
        it { response.code.should == '404'  }
        it { response.should render_template('public/404.html') }
      end
    end
    describe 'PUT' do
      it_should_behave_like 'update ticket'
    end
  end

end
