require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "resource(:projects)" do
  describe "GET" do
    
    before(:each) do
      Project.all.each{|project| project.destroy}
      @response = request(resource(:projects))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains an empty list of projects" do
      @response.should_not have_xpath("//h2")
    end
    
  end
  
  describe "GET" do
    before(:each) do
      2.of{Project.gen}
      @response = request(resource(:projects))
    end
    
    it "has a list of projects" do
      @response.should have_xpath("//h2")
    end
  end

  describe 'with admin user' do

    describe "a successful POST" do
      before(:each) do
        Project.all.each{|p| p.destroy}
        login_admin
        @response = request(resource(:projects), :method => "POST", :params => {:project => { :name => 'oupsnow' }})
      end
      
      it "redirects to resource(:projects)" do
        @response.should redirect_to(resource(Project.first(:name => 'oupsnow'), :tickets), :message => {:notice => "project was successfully created"})
      end
      
    end
  end
end

describe "resource(@project)" do 

  describe 'with admin user' do
    describe "a successful DELETE" do
       before(:each) do
         login_admin
         @project = Project.gen
         @response = request(resource(@project))
       end

       it "should redirect to the index action" do
         @response.should redirect_to(resource(@project, :overview))
       end

    end
  end
end

describe "resource(:projects, :new)" do
  describe 'with user logged' do
    before(:each) do
      login
      @response = request(resource(:projects, :new), :method => 'GET')
    end
    
    it "responds successfully" do
      @response.status.should == 401
    end
  end

  describe 'with admin user' do
    before(:each) do
      login_admin
      @response = request(resource(:projects, :new), :method => 'GET')
    end
    
    it "responds successfully" do
      @response.should be_successful
    end
  end
end

describe "resource(@project, :edit)" do
  describe 'with user logged' do
    before(:each) do
      login
      @response = request(resource(Project.gen, :edit))
    end
    
    it "responds successfully" do
      @response.status.should == 401
    end
  end

  describe 'with admin logged' do
    before(:each) do
      login_admin
      @response = request(resource(Project.gen, :edit))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end
  end
end

describe "resource(@project)" do
  
  describe "GET" do
    before(:each) do
      @project = Project.gen
      @response = request(resource(@project))
    end
  
    it "responds successfully" do
      @response.should redirect_to(resource(@project, :overview))
    end
  end
  
  describe "PUT" do
    describe 'with admin user' do
      before(:each) do
        login_admin
        @project = Project.first
        @response = request(resource(@project), :method => "PUT", :params => {:project => {:id => @project.id, :name => 'update_name'}} )
      end
    
      it "redirect to the article show action" do
        @response.should redirect_to(resource(@project, :tickets))
      end
    end
  end
  
end


describe 'it should be successful' , :shared => true do
  it 'should be successful' do
    @response.should be_successful
  end
end

describe 'resource(@project, :overview)' do
  def test_request
    @response = request(resource(@project, :overview))
  end

  describe 'anonymous user' do
    before :each do
      logout
      Project.gen unless Project.first
      @project = Project.first
      test_request
    end

    it_should_behave_like 'it should be successful'
  end

  describe 'login user' do
    before :each do
      login
      Project.gen unless Project.first
      @project = Project.first
      test_request
    end

    it_should_behave_like 'it should be successful'
  end

  describe 'admin user' do
    before :each do
      login_admin
      Project.gen unless Project.first
      @project = Project.first
      test_request
    end

    it_should_behave_like 'it should be successful'
  end

end
