require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "resource(:milestones)" do
  describe "GET" do
    
    before(:each) do
      login
      @response = request(resource(Project.first, :milestones))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of milestones" do
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET" do
    before(:each) do
      login
      need_a_milestone
      @response = request(resource(Project.first, :milestones))
    end
    
    it "has a list of milestones" do
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      login_admin
      @response = request(resource(Project.first, :milestones), :method => "POST", 
        :params => { :milestone => { :name => 'New Milestone' }})
    end
    
    it "redirects to resource(:milestones)" do
      @response.should redirect_to(resource(Project.first, Milestone.first(:name => 'New Milestone')), :message => {:notice => "milestone was successfully created"})
    end
    
  end
end

describe "resource(@milestone)" do 
  describe "a successful DELETE" do
     before(:each) do
       login_admin
       @response = request(resource(Project.first, Project.first.milestones.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(Project.first, :milestones))
     end

   end
end

describe "resource(:milestones, :new)" do
  before(:each) do
    login_admin
    @response = request(resource(Project.first, :milestones, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@milestone, :edit)" do
  before(:each) do
    login_admin
    @response = request(resource(Project.first, Project.first.milestones.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@milestone)" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Project.first, Project.first.milestones.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      login_admin
      @project = Project.first
      @milestone = @project.milestones.first
      @response = request(resource(@project, @milestone), :method => "PUT", 
        :params => { :milestone => {:id => @milestone.id, :name => 'HELLO'} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@project, @milestone))
    end


    it "change name of milestone" do
      @milestone.reload.name.should == 'HELLO'
    end
  end
  
end

