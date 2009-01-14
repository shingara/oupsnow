require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

def create_user_by_request
  request(resource(:users), :method => "POST", 
    :params => { :user => { :login => 'shingara', 
      :email => 'cyril.mougel@gmail.com',
      :password => 'tintinpouet',
      :password_confirmation => 'tintinpouet' }})
end

given "a user exists" do
  login
end

describe "resource(:users)" do

  describe "a successful POST" do
    before(:each) do
      User.all.each {|u| u.destroy}
      @response = create_user_by_request
    end
    
    it "redirects to resource(:users)" do
      @response.should redirect_to(resource(User.first, :edit), :message => {:notice => "user was successfully created"})
    end
    
  end
end

describe "resource(@user)" do 
  describe "a successful DELETE", :given => "a user exists" do
     before(:each) do
       @response = request(resource(User.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:users))
     end

   end
end

describe "resource(:users, :new)" do
  before(:each) do
    @response = request(resource(:users, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@user, :edit)", :given => "a user exists" do
  describe 'with user login' do
    before(:each) do
      @user = login
    end

    it "responds successfully if it's own edit" do
      response = request(resource(@user, :edit))
      response.should be_successful
    end

    it "should return 401 if not own edit" do
      User.gen
      response = request(resource(User.first(:login.not => @user.login) , :edit))
      response.status.should == 401
    end
  end
end

describe "resource(@user)", :given => "a user exists" do
  
  describe "PUT" do
    before(:each) do
      @user = login
      @response = request(resource(@user), :method => "PUT", 
        :params => { :user => {:id => @user.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(:projects))
    end
  end
  
end

