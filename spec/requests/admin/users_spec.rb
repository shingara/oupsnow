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
    end

    it "should redirect to the index action" do
      @response = request(resource(:admin, User.first), :method => "DELETE")
      @response.should redirect_to(resource(:admin, :users))
    end

    it "should not delete user" do
      lambda do
        @response = request(resource(:admin, User.first), :method => "DELETE")
        User.first.deleted_at.should_not nil
      end.should_not change(User, :count)
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

describe "update_all" do
  before(:each) do
    login_admin
    @response = request(url(:update_all_admin_users), :method => 'PUT', :params => {:user_admin => {User.first.id => 1}})
  end

  it 'should redirect' do
    @response.should redirect_to(resource(:admin, :users))
  end
end
