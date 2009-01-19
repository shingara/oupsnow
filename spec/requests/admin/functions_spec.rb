require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe "resource(:functions)" do
  describe 'admin user' do
    before :each do
      login_admin
    end
    
    describe "GET" do
      before(:each) do
        @response = request(resource(:admin, :functions))
      end
      
      it "has a list of functions" do
        @response.should have_xpath("//table/tbody/tr/td")
      end
    end
    
    describe "a successful POST" do
      before(:each) do
        @response = request(resource(:admin, :functions), :method => "POST", 
          :params => { :function => { :name => 'foo' }})
      end
      
      it "redirects to resource(:functions)" do
        @response.should redirect_to(resource(:admin, :functions), :message => {:notice => "function was successfully created"})
      end
      
    end
  end
end


describe "resource(:functions, :new)" do
  before(:each) do
    login_admin
    @response = request(resource(:admin, :functions, :new))
  end

  it "responds successfully" do
    @response.should be_successful
  end
end

