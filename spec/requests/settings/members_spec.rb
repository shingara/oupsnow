require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

given 'a member exists' do
  Project.all.destroy!
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
      before(:each) do
        login_admin
        @response = request(url(:project_settings_member, Project.first), :method => "POST", 
          :params => { :member => { :email => 'shingara@gmail.com' }})
      end
      
      it "redirects to list of member " do
        @response.should redirect_to(url(:project_setting_members, Project.first), :message => {:notice => "Email send to shingara.gmail"})
      end
    end
    
  end
end

describe "resource(@member)" do 
  describe "a successful DELETE" do
     before(:each) do
       @response = request(resource(Member.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:members))
     end

   end
end

describe "resource(:members, :new)" do
  before(:each) do
    @response = request(resource(:members, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@member, :edit)", :given => "a member exists" do
  before(:each) do
    @response = request(resource(Member.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@member)", :given => "a member exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Member.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      login_admin
      @member = Member.first
      @response = request(url(:project_settings_member, Project.first, @member), :method => "PUT", 
        :params => { :member => {:id => @member.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(url(:project_settings_members, Project.first))
    end
  end
  
end

