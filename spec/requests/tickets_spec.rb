require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a ticket exists" do
  p = Project.gen
  Ticket.gen(:project_id => p.id,
            :member_create_id => p.members.first.user_id)
end

given "logged user" do
  login
end

describe "resource(Project.first, :tickets)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(Project.first, :tickets))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of tickets" do
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a ticket exists" do
    before(:each) do
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

    def post_request(pf)
      @response = request(resource(pf, :tickets), :method => "POST", 
        :params => { :ticket => { :title => 'a new ticket'},
                      :project_id => pf.id})
    end

    describe 'with anonymous user' do
      before :each do
        logout
        Project.gen unless Project.first
        post_request(Project.first)
      end

      it 'should not access' do
        @response.status.should == 401
      end
    end

    describe 'ticket creation success', :shared => true do

      it 'should create ticket' do
        Ticket.first.should_not be_nil
      end

      it "redirects to resource(Project.first, :tickets)" do
        @response.should redirect_to(resource(Project.first, Ticket.first), :message => {:notice => "ticket was successfully created"})
      end

      it 'project should have one ticket' do
        @project.tickets.should have(1).items
      end
      
      after :each do
        Ticket.all.each {|t| t.destroy}
      end

    end


    describe 'with user logged, member of project but not admin' do
      before(:each) do
        login
        @project = Project.first
        @project.members.build(:user_id => User.first(:login => 'shingara').id,
                         :function_id => Function.first.id)
        @project.save
        Ticket.all.each{|t| t.destroy}
        post_request(@project)
      end

      it_should_behave_like 'ticket creation success'
    end

    describe 'with user logged, no member of project but not admin' do
      before(:each) do
        login
        @project = Project.first
        delete_default_member_from_project(@project)
        Ticket.all.each{|t| t.destroy}
        post_request(@project)
      end

      it_should_behave_like 'ticket creation success'
    end
    
  end
end

describe "resource(Project.first, :tickets, :new)" do
  before(:each) do
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

describe "resource(Project.first, @ticket, :edit_main_description)", :given => "a ticket exists" do
  def req
    @response = request(resource(Project.first, Ticket.first, :edit_main_description))
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

describe "resource(Project.first, @ticket, :update_main_description)", :given => "a ticket exists" do
  def req
    @response = request(resource(Project.first, Ticket.first, :update_main_description), :method => "PUT", :params => {:ticket => {:description => 'yahoo'}})
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

describe "resource(Project.first, @ticket)", :given => "a ticket exists" do
  
  describe "GET" do
    before(:each) do
      p = Project.gen
      t = Ticket.gen(:project_id => p.id,
                    :member_create_id => p.members.first.user_id)
      @response = request(resource(p,t))
    end

    after :each do
      Ticket.all.each {|t| t.destroy}
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    describe "with user logged", :given => 'logged user' do
      before(:each) do
        @project = Project.gen
        @ticket = Ticket.gen(:project_id => @project.id,
                            :member_create_id => @project.members.first.user_id)
        @response = request(resource(@project, @ticket), :method => "PUT", 
          :params => { :ticket => {:id => @ticket.id} })
      end

      after :each do
        Ticket.all.each {|t| t.destroy}
      end
    
      it "redirect to the article show action" do
        @response.should redirect_to(resource(@project, @ticket))
      end
    end
  end
  
end

