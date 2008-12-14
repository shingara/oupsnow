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

  describe 'with user logged' do

    describe "a successful POST" do
      before(:each) do
        Project.all.destroy!
        @response = post(resource(:projects), :project => { :name => 'oupsnow' }) do |controller|
          controller.session.should_receive(:authenticated?).and_return(true)
          yield controller if block_given?
        end
      end
      
      it "redirects to resource(:projects)" do
        @response.should redirect_to(resource(Project.first), :message => {:notice => "project was successfully created"})
      end
      
    end
  end
end

describe "resource(@project)" do 

  describe 'with user logged' do
    describe "a successful DELETE" do
       before(:each) do
         @response = delete(resource(Project.gen)) do |controller|
            controller.session.should_receive(:authenticated?).and_return(true)
            yield controller if block_given?
         end
       end

       it "should redirect to the index action" do
         @response.should redirect_to(resource(:projects))
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
      @response.should redirect_to(resource(@project, :tickets))
    end
  end
  
  describe "PUT" do
    describe 'with user logged' do
      before(:each) do
        @project = Project.gen
        @response = put(resource(@project), :project => {:id => @project.id, :name => 'update_name'} ) do |controller|
          controller.session.should_receive(:authenticated?).and_return(true)
          yield controller if block_given?
        end
      end
    
      it "redirect to the article show action" do
        @response.should redirect_to(resource(@project))
      end
    end
  end
  
end

