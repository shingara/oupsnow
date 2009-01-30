require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a milestone exists" do
  Milestone.all.destroy!
  request(resource(:milestones), :method => "POST", 
    :params => { :milestone => { :id => nil }})
end

describe "resource(:milestones)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:milestones))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of milestones" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a milestone exists" do
    before(:each) do
      @response = request(resource(:milestones))
    end
    
    it "has a list of milestones" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Milestone.all.destroy!
      @response = request(resource(:milestones), :method => "POST", 
        :params => { :milestone => { :id => nil }})
    end
    
    it "redirects to resource(:milestones)" do
      @response.should redirect_to(resource(Milestone.first), :message => {:notice => "milestone was successfully created"})
    end
    
  end
end

describe "resource(@milestone)" do 
  describe "a successful DELETE", :given => "a milestone exists" do
     before(:each) do
       @response = request(resource(Milestone.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:milestones))
     end

   end
end

describe "resource(:milestones, :new)" do
  before(:each) do
    @response = request(resource(:milestones, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@milestone, :edit)", :given => "a milestone exists" do
  before(:each) do
    @response = request(resource(Milestone.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@milestone)", :given => "a milestone exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Milestone.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @milestone = Milestone.first
      @response = request(resource(@milestone), :method => "PUT", 
        :params => { :milestone => {:id => @milestone.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@milestone))
    end
  end
  
end

