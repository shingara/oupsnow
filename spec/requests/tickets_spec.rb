require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "resource(Project.first, :tickets)" do
  describe "GET" do
    
    before(:each) do
      login
      @response = request(resource(Project.first, :tickets))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of tickets" do
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET" do
    before(:each) do
      login
      @response = request(resource(Project.first, :tickets))
    end

    after(:each) do
      Ticket.all.each {|t| t.destroy}
    end
    
    it "has a list of tickets" do
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do

    def post_request(project, options = {})
      @response = request(resource(project, :tickets), :method => "POST", 
                          :params => { :ticket => { :title => 'a new ticket',
                            :state_id => State.first.id},
                            :project_id => project.id}.merge(options))
    end

    describe 'with anonymous user' do
      before :each do
        logout
        make_project unless Project.first
        post_request(Project.first)
      end

      it 'should not access' do
        @response.status.should == 401
      end
    end

    describe 'ticket creation success', :shared => true do

      before :each do
        @project.tickets.each{|t| t.destroy}
        post_request(@project)
      end

      it 'should create ticket' do
        @project.tickets.first.should_not be_nil
      end

      it "redirects to resource(Project.first, :tickets)" do
        @response.should redirect_to(resource(@project, @project.tickets.first), 
                                     :message => {:notice => "ticket was successfully created"})
      end

      it 'project should have one ticket' do
        @project.tickets.should have(1).items
      end
      
    end


    describe 'with user logged, member of project but not admin' do
      before(:each) do
        login
        @project = Project.first
        pm = ProjectMember.new(:user => User.first(:conditions => {:login => 'shingara'}),
                          :function => Function.first)
        @project.project_members << pm
        @project.save
      end

      it_should_behave_like 'ticket creation success'

    end

    describe 'with user logged, no member of project but not admin' do
      before(:each) do
        login
        @project = Project.first
        delete_default_member_from_project(@project)
      end

      it_should_behave_like 'ticket creation success'

    end
    
  end
end

describe "resource(Project.first, :tickets, :new)" do
  before(:each) do
    logout
    create_default_admin unless Project.first
    @response = request(resource(Project.first, :tickets, :new))
  end
  
  it "responds successfully" do
    @response.status.should == 401
  end
end

describe "doesn't access to anonymous", :shared => true do
  before :each do
    req
  end

  it 'should respond 401' do
    @response.status.should == 401
  end

  it 'should not update ticket description' do
    Ticket.first.description.should_not == 'yahoo'
  end

end

describe "doesn't access with user logged", :shared => true do

  before :each do
    login
    req
  end

  it "responds successfully" do
    @response.status.should == 401
  end

  it 'should not update ticket description' do
    Ticket.first.description.should_not == 'yahoo'
  end
end

describe "resource(Project.first, @ticket, :edit_main_description)" do
  def req
    @response = request(resource(Project.first, Ticket.first, :edit_main_description))
  end

  before :each do
    login
  end

  it_should_behave_like "doesn't access to anonymous"
  it_should_behave_like "doesn't access with user logged"


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

describe "resource(Project.first, @ticket, :update_main_description)" do
  def req
    @response = request(resource(Project.first, Ticket.first, :update_main_description), 
                        :method => "PUT", 
                        :params => {:ticket => {:description => 'yahoo',
                                                :title => Ticket.first.title}})
  end

  before :each do
    login
  end

  it_should_behave_like "doesn't access to anonymous"
  it_should_behave_like "doesn't access with user logged"


  describe 'with admin user logged' do

    before :each do
      login_admin
      req
    end

    it "responds successfully" do
      @response.should redirect_to(resource(Project.first, Ticket.first))
    end

    it "should update ticket description" do
      Ticket.first.description.should == 'yahoo'
    end
  end
end

describe "resource(Project.first, @ticket)" do

  before :each do
    login
  end
  
  describe "GET" do
    before(:each) do
      p = make_project
      t = Ticket.make(:project => p,
                    :user_creator => p.project_members.first.user)
      @response = request(resource(p,t))
    end

    after :each do
      Ticket.destroy_all
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do

    def put_request
      @project = Project.first
      @ticket = @project.tickets.first
      @response = request(resource(@project, @ticket), 
                          :method => "PUT", 
                          :params => { :ticket => {:description => 'new comment',
                                                    :state_id => State.first.id} })
    end

    describe "with anonymous" do
      before :each do
        create_default_admin
        logout
        t = Project.first.tickets.first
        t.ticket_updates = []
        t.save
        put_request
      end

      it 'should be successful' do
        @response.status.should == 401
      end

      it 'should not change ticket' do
        @ticket.should == Project.first.tickets.first
      end

      it 'should not create ticket update' do
        Project.first.tickets.first.ticket_updates.should be_empty
      end
    end

    describe "with user logged" do
      before(:each) do
        login
        put_request
      end

      after :each do
        Ticket.destroy_all
      end
    
      it "redirect to the article show action" do
        @response.should redirect_to(resource(@project, @ticket))
      end
    end
  end
  
end

