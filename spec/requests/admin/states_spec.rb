require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe "resource(:admin,:states)" do
  describe "GET" do
    
    before(:each) do
      login_admin
      @response = request(resource(:admin,:states))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of states" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET" do
    before(:each) do
      login_admin
      @response = request(resource(:admin,:states))
    end
    
    it "has a list of states" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      login_admin
      @response = request(resource(:admin,:states), :method => "POST", 
        :params => { :state => { :name => 'FOO' }})
    end
    
    it "redirects to resource(:admin,:states)" do
      @response.should redirect_to(resource(:admin, :states), :message => {:notice => "State was successfully created"})
    end
    
  end
end

describe "resource(:admin,@state)" do 
  describe "a successful DELETE" do
     before(:each) do
       login_admin
       @response = request(resource(:admin, State.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:admin,:states))
     end

   end
end

describe "resource(:admin,:states, :new)" do
  before(:each) do
    login_admin
    @response = request(resource(:admin,:states, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(:admin,@state, :edit)" do
  before(:each) do
    login_admin
    @response = request(resource(:admin,State.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(:admin,@state)" do
  
  describe "GET" do
    before(:each) do
      login_admin
      @response = request(resource(:admin,State.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      login_admin
      @state = State.first
      @response = request(resource(:admin,@state), :method => "PUT", 
        :params => { :state => {:id => @state.id, :name => 'FOO'} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(:admin,@state))
    end

    it 'should change the name of state' do
      @state.reload.name.should == 'FOO'
    end
  end
  
end

