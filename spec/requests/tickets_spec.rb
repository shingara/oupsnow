require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a ticket exists" do
  Project.gen
  Ticket.all.destroy!
  request(resource(Project.first, :tickets), :method => "POST",
    :params => { :ticket => { :title => 'good ticket', :description => 'a good description'}})
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
    
    it "has a list of tickets" do
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Project.gen
      Ticket.all.destroy!
      @response = request(resource(Project.first, :tickets), :method => "POST", 
        :params => { :ticket => { :title => 'a new ticket' }})
    end
    
    it "redirects to resource(Project.first, :tickets)" do
      @response.should redirect_to(resource(Project.first, Ticket.first), :message => {:notice => "ticket was successfully created"})
    end
    
  end
end

describe "resource(Project.first, @ticket)" do 
  describe "a successful DELETE", :given => "a ticket exists" do
     before(:each) do
       @response = request(resource(Project.first, Ticket.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(Project.first, :tickets))
     end

   end
end

describe "resource(Project.first, :tickets, :new)" do
  before(:each) do
    @response = request(resource(Project.first, :tickets, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(Project.first, @ticket, :edit)", :given => "a ticket exists" do
  before(:each) do
    @response = request(resource(Project.first, Ticket.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(Project.first, @ticket)", :given => "a ticket exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Project.first, Ticket.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @ticket = Ticket.first
      @response = request(resource(Project.first, @ticket), :method => "PUT", 
        :params => { :ticket => {:id => @ticket.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(Project.first, @ticket))
    end
  end
  
end

