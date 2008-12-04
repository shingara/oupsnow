require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a ticket exists" do
  Ticket.all.destroy!
  request(resource(:tickets), :method => "POST", 
    :params => { :ticket => { :id => nil }})
end

describe "resource(:tickets)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:tickets))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of tickets" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a ticket exists" do
    before(:each) do
      @response = request(resource(:tickets))
    end
    
    it "has a list of tickets" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Ticket.all.destroy!
      @response = request(resource(:tickets), :method => "POST", 
        :params => { :ticket => { :id => nil }})
    end
    
    it "redirects to resource(:tickets)" do
      @response.should redirect_to(resource(Ticket.first), :message => {:notice => "ticket was successfully created"})
    end
    
  end
end

describe "resource(@ticket)" do 
  describe "a successful DELETE", :given => "a ticket exists" do
     before(:each) do
       @response = request(resource(Ticket.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:tickets))
     end

   end
end

describe "resource(:tickets, :new)" do
  before(:each) do
    @response = request(resource(:tickets, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@ticket, :edit)", :given => "a ticket exists" do
  before(:each) do
    @response = request(resource(Ticket.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@ticket)", :given => "a ticket exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Ticket.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @ticket = Ticket.first
      @response = request(resource(@ticket), :method => "PUT", 
        :params => { :ticket => {:id => @ticket.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@ticket))
    end
  end
  
end

