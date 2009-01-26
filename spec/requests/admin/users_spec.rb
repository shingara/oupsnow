require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe "resource(:users)" do
  describe "GET"  do
    before(:each) do
      login_admin
      @response = request(resource(:admin, :users))
    end
    
    it "has a list of users" do
      @response.should have_xpath("//table/tbody/tr/td")
    end
  end
end

describe "resource(@user)" do 
  describe "a successful DELETE" do
    before(:each) do
      login_admin
      @response = request(resource(:admin, User.first), :method => "DELETE")
    end

    it "should redirect to the index action" do
      @response.should redirect_to(resource(:admin, :users))
    end
  end
end

describe "resource(@user)" do
  
  describe "GET" do
    before(:each) do
      login_admin
      @response = request(resource(:admin, User.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
end
