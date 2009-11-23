require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe TicketUpdatesController do

  before do
    @project = make_project
    State.make
    @ticket = make_ticket(:project => @project)
    make_ticket_update(@ticket, :project => @project, :description => 'cool')
    @ticket = Ticket.find(@ticket.id)
  end

  describe 'anonymous user' do
    before do
      login_anonymous
    end

    describe 'edit' do
      it 'should not access' do
        get :edit, :project_id => @project.id, :ticket_id => @ticket.num,
          :id => @ticket.ticket_updates.first.num
        response.should redirect_to(new_user_session_url(:unauthenticated=>true))
      end
    end

    describe 'update' do
      it 'should not access' do
        put :update, :project_id => @project.id,
          :ticket_id => @ticket.num,
          :id => @ticket.ticket_updates.first.num,
          :ticket_update => {:description => 'yahoo',
            :state_id => State.first.id}
        response.should redirect_to(new_user_session_url(:unauthenticated=>true))
      end
    end

  end

  describe 'logged user not admin of project' do
    before do
      login_request
    end

    describe 'edit' do
      before do
        get :edit, :project_id => @project.id, :ticket_id => @ticket.num,
          :id => @ticket.ticket_updates.first.num
      end
      it { response.should redirect_to(new_user_session_url) }

    end

    describe 'update' do
      before do
        put :update, :project_id => @project.id,
          :ticket_id => @ticket.num,
          :id => @ticket.ticket_updates.first.num,
          :ticket_update => {:description => 'yahoo',
            :state_id => State.first.id}
      end
      it { response.should redirect_to(new_user_session_url) }
      it 'should not update ticket_update' do
        Ticket.find(@ticket.id).ticket_updates.first.description.should_not == 'yahoo'
      end

    end

  end

  describe 'logged user admin of project' do
    before do
      login_admin
    end
    describe 'edit' do
      before do
        get :edit, :project_id => @project.id, :ticket_id => @ticket.num,
          :id => @ticket.ticket_updates.first.num
      end
      it { response.should be_success }
    end

    describe 'update' do
      describe 'with good ticket_update id' do
        before do
          put :update, :project_id => @project.id,
            :ticket_id => @ticket.num,
            :id => @ticket.ticket_updates.first.num,
            :ticket_update => {:description => 'yahoo',
              :state_id => State.first.id}
        end
        it { response.should redirect_to(project_ticket_url(@project, @ticket)) }
        it 'should update ticket_update description' do
          Ticket.find(@ticket.id).ticket_updates.first.description.should == 'yahoo'
        end
      end
      describe 'with bad ticket_update id' do
        before do
          put :update, :project_id => @project.id,
            :ticket_id => @ticket.num,
            :id => (@ticket.ticket_updates.first.num + 100),
            :ticket_update => {:description => 'yahoo',
              :state_id => State.first.id}
        end
        it { response.should render_template('public/404.html') }
        it 'should not update ticket_update description' do
          Ticket.find(@ticket.id).ticket_updates.first.description.should_not == 'yahoo'
        end
      end
    end
  end
end
