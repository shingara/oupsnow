require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

given 'a member exists' do
  Project.all.each {|p| p.destroy}
  create_default_admin
  Project.gen
end

describe "resource(:members)", :given => 'a member exists' do

  describe "GET" do

    describe 'with user admin' do
      before(:each) do
        login_admin
        @response = request(url(:project_settings_members, Project.first))
      end
      
      it "responds successfully" do
        @response.should be_successful
      end

      it "contains a list of members" do
        @response.should have_xpath("//table/tbody/tr/td")
      end
    end

    describe 'with user logged' do
      before :each do
        login
        @response = request(url(:project_settings_members, Project.first))
      end

      it 'should render 401' do
        @response.status.should == 401
      end
    end
    
  end
  
  describe "a successful POST", :given => 'a member exists' do

    describe 'with logged admin' do
      it 'should create member' do
        login_admin
        need_developper_function
        lambda {
          @response = request(url(:project_settings_members, User.first(:login => 'admin').projects.first), :method => "POST", 
            :params => { :member => { :user_id => User.gen.id }})
          @response.should redirect_to(url(:project_settings_members, User.first(:login => 'admin').projects.first), :message => {:notice => "Email send to shingara.gmail"})
        }.should change(Member, :count)
      end
    end
    
  end
end

describe "resource(:members, :new)" do
  before(:each) do
    login_admin
    @response = request(resource(Project.first, :settings, :members, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@member)", :given => "a member exists" do
  
  describe "GET" do
    before(:each) do
      login_admin
      Member.gen(:project_id => Project.first.id) unless Member.first(:project_id => Project.first.id)
      @response = request(resource(Project.first, :settings, Member.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
end

