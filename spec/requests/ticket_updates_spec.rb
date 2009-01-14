require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')


describe "doesn't access to anonymous ticket_update", :shared => true do
  before :each do
    create_default_admin
    request('/logout')
    req
  end

  it 'should respond 401' do
    @response.status.should == 401
  end

  it 'should not update ticket description' do
    Ticket.first.ticket_updates.first.description.should_not == 'yahoo'
  end

end

describe "doesn't access with user logged ticket_update", :shared => true do

  before :each do
    request('/logout')
    login
    req
  end

  it "responds successfully" do
    @response.status.should == 401
  end

  it 'should not update ticket description' do
    Ticket.first.ticket_updates.first.description.should_not == 'yahoo'
  end
end

describe "resource(Project.first, @ticket, @ticket_update, :edit)" do
  def req
    @response = request(resource(Project.first, Ticket.first, Ticket.first.ticket_updates.first, :edit))
  end

  it_should_behave_like "doesn't access to anonymous ticket_update"
  it_should_behave_like "doesn't access with user logged ticket_update"


  describe 'with admin user logged' do

    before :each do
      login_admin
      req
    end

    it "responds successfully" do
      @response.should be_successful
    end
  end
end

describe "resource(Project.first, @ticket, @ticket_update) PUT" do
  def req
    @response = request(resource(Project.first, Project.first.tickets.first, Project.first.tickets.first.ticket_updates.first), 
                        :method => "PUT", 
                        :params => {:ticket_update => {:description => 'yahoo'}})
  end

  it_should_behave_like "doesn't access to anonymous ticket_update"
  it_should_behave_like "doesn't access with user logged ticket_update"


  describe 'with admin user logged' do

    before :each do
      login_admin
      req
    end

    it "responds successfully" do
      @response.should redirect_to(resource(Project.first, Ticket.first))
    end

    it "should update ticket description" do
      Ticket.first.ticket_updates.first.description.should == 'yahoo'
    end
  end
end
