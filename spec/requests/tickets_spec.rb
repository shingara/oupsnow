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
    before(:each) do
      Project.gen
      login
      pf = Project.first
      pf.members.build(:user_id => User.first(:login => 'shingara').id,
                       :function_id => Function.first.id)
      pf.save
      Ticket.all.each{|t| t.destroy}
      @response = request(resource(pf, :tickets), :method => "POST", 
        :params => { :ticket => { :title => 'a new ticket'},
                      :project_id => pf.id})
    end

    after :each do
      Ticket.all.each {|t| t.destroy}
    end
    
    it "redirects to resource(Project.first, :tickets)" do
      @response.should redirect_to(resource(Project.first, Ticket.first), :message => {:notice => "ticket was successfully created"})
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

describe "resource(Project.first, @ticket, :edit)", :given => "a ticket exists" do
  before(:each) do
    @response = request(resource(Project.first, Ticket.first, :edit))
  end

  after :each do
    Ticket.all.each {|t| t.destroy}
  end
  
  it "responds successfully" do
    @response.status.should == 401
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

