require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

given "a state exists" do
  State.all.destroy!
  request(resource(:states), :method => "POST", 
    :params => { :state => { :id => nil }})
end

describe "resource(:states)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:states))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of states" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a state exists" do
    before(:each) do
      @response = request(resource(:states))
    end
    
    it "has a list of states" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      State.all.destroy!
      @response = request(resource(:states), :method => "POST", 
        :params => { :state => { :id => nil }})
    end
    
    it "redirects to resource(:states)" do
      @response.should redirect_to(resource(State.first), :message => {:notice => "state was successfully created"})
    end
    
  end
end

describe "resource(@state)" do 
  describe "a successful DELETE", :given => "a state exists" do
     before(:each) do
       @response = request(resource(State.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:states))
     end

   end
end

describe "resource(:states, :new)" do
  before(:each) do
    @response = request(resource(:states, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@state, :edit)", :given => "a state exists" do
  before(:each) do
    @response = request(resource(State.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@state)", :given => "a state exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(State.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @state = State.first
      @response = request(resource(@state), :method => "PUT", 
        :params => { :state => {:id => @state.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@state))
    end
  end
  
end

