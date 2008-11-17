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
      projects = list_mock_project
      Project.should_receive(:all).and_return(projects)
      @response = request(resource(:projects))
    end
    
    it "has a list of projects" do
      @response.should have_xpath("//h2")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Project.all.destroy!
      @response = request(resource(:projects), :method => "POST", 
        :params => { :project => { :name => 'oupsnow' }})
    end
    
    it "redirects to resource(:projects)" do
      @response.should redirect_to(resource(Project.first), :message => {:notice => "project was successfully created"})
    end
    
  end
end

describe "resource(@project)" do 
  describe "a successful DELETE" do
     before(:each) do
       @response = request(resource(Project.gen), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:projects))
     end

   end
end

describe "resource(:projects, :new)" do
  before(:each) do
    @response = request(resource(:projects, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@project, :edit)" do
  before(:each) do
    @response = request(resource(Project.gen, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@project)" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Project.gen))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @project = Project.gen
      @response = request(resource(@project), :method => "PUT", 
        :params => { :project => {:id => @project.id, :name => 'update_name'} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@project))
    end
  end
  
end

