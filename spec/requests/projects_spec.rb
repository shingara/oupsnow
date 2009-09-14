require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "resource(:projects)" do
  describe "GET" do
    
    before(:each) do
      Project.destroy_all
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
      2.of{make_project}
      @response = request(resource(:projects))
    end
    
    it "has a list of projects" do
      @response.should have_xpath("//h2")
    end
  end

  describe 'with admin user' do

    describe "a successful POST" do
      before(:each) do
        Project.destroy_all
        login_admin
        @response = request(resource(:projects), :method => "POST", :params => {:project => { :name => 'oupsnow' }})
      end
      
      it "redirects to resource(:projects)" do
        @response.should redirect_to(resource(Project.first(:conditions => {:name => 'oupsnow'}), :tickets), 
                                     :message => {:notice => "project was successfully created"})
      end
      
    end
  end
end

describe "resource(@project) DELETE" do 

  describe 'with admin user' do
    before(:each) do
      login_admin
      @project = make_project
      @response = request(resource(@project, :delete))
    end

    it "should redirect to the index action" do
      @response.should be_successful
    end

  end

  describe 'with user project admin' do
    before(:each) do
      user = login
      @project = make_project
      @project.add_member(user, Function.admin)
      @response = request(resource(@project, :delete))
    end

    it "should define like not authorized" do
      @response.status.should == 401
    end

  end

  describe 'with base user' do
    before(:each) do
      user = login
      @project = make_project
      @project.add_member(user, function_not_admin)
      @response = request(resource(@project, :delete))
    end

    it "should define like not authorized" do
      @response.status.should == 401
    end

  end
end

describe "resource(@project) DESTROY" do 

  describe 'with admin user' do
    before(:each) do
      login_admin
      @project = make_project
      @response = request(resource(@project), :method => "DELETE")
    end

    it "should redirect to the index action" do
      @response.should redirect_to(resource(:projects))
    end

    it 'should delete project' do
      Project.find_by__id(@project.id).should be_nil
    end

  end

  describe 'with user project admin' do
    before(:each) do
      user = login
      @project = make_project
      @project.add_member(user, Function.admin)
      @response = request(resource(@project), :method => "DELETE")
    end

    it "should define like not authorized" do
      @response.status.should == 401
    end

  end

  describe 'with base user' do
    before(:each) do
      user = login
      @project = make_project
      @project.add_member(user, function_not_admin)
      @response = request(resource(@project), :method => "DELETE")
    end

    it "should define like not authorized" do
      @response.status.should == 401
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
      @response = request(resource(make_project, :edit))
    end
    
    it "responds successfully" do
      @response.status.should == 401
    end
  end

  describe 'with admin logged' do
    before(:each) do
      login_admin
      @response = request(resource(make_project, :edit))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end
  end
end

describe "resource(@project)" do
  
  describe "GET" do
    before(:each) do
      @project = make_project
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
      make_project unless Project.first
      @project = Project.first
      test_request
    end

    it_should_behave_like 'it should be successful'
  end

  describe 'login user' do
    before :each do
      login
      @project = Project.first || make_project
      test_request
    end

    it_should_behave_like 'it should be successful'
  end

  describe 'admin user' do
    before :each do
      login_admin
      @project = Project.first || make_project
      test_request
    end

    it_should_behave_like 'it should be successful'
  end

end
