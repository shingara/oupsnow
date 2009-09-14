require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')


describe "resource(:priorities)" do
  describe 'admin user' do
      
    describe "GET" do
      before(:each) do
        login_admin
        Priority.make
        @response = request(resource(:admin, :priorities))
      end
      
      it "has a list of priorities" do
        @response.should have_xpath("//table/tbody/tr/td")
      end
    end
    
    describe "a successful POST" do
      before(:each) do
        Priority.all(:conditions => {:name => 'foo'}).each {|priority| priority.destroy}
        login_admin
        @response = request(resource(:admin, :priorities), :method => "POST", 
          :params => { :priority => { :name => 'foo' }})
      end
      
      it "redirects to resource(:priorities)" do
        @response.should redirect_to(resource(:admin, :priorities), :message => {:notice => "priority was successfully created"})
      end
      
    end
  end
end

describe "resource(:priorities, :new)" do
  before(:each) do
    login_admin
    @response = request(resource(:admin, :priorities, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end
