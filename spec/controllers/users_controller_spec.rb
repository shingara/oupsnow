require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe UsersController do

  describe "resource(:users)" do

    describe "a successful POST" do
      before(:each) do
        User.make(:admin) unless User.first(:conditions => {:login => 'Admin'}) # a admin user is needed in bootstrap
        post :create, :user => {:email => 'cyril.mougel@gmail.com',
          :login => 'shingara',
          :password => 'tintinpouet',
          :password_confirmation => 'tintinpouet'}
      end

      it "redirects to resource(:users)" do
        response.should redirect_to(edit_user_url(User.first(:login => 'shingara')))
        flash[:notice].should == "User was successfully created"
      end

    end
  end

  describe "resource(@user)" do 
    describe "a successful DELETE" do
      before(:each) do
        login_request
        @user = User.first
        delete :destroy, :id => @user.id
      end

      it "should redirect to the index action" do
        response.should redirect_to(users_url)
      end
    end
  end

  describe "resource(:users, :new)" do
    before(:each) do
      get :new
    end

    it "responds successfully" do
      @response.should be_success
    end
  end

  describe "resource(@user, :edit)" do

    before :each do
      login_request
    end

    describe 'with user login' do
      before(:each) do
        @user = login_request
      end

      it "responds successfully if it's own edit" do
        get :edit, :id => @user.id
        response.should be_success
      end

      it "should return 401 if not own edit" do
        User.make
        get :edit, :id => User.first(:conditions => {:login => {'$ne' => @user.login}}).id
        response.code.should == "401"
        response.should render_template('exceptions/unauthenticated')
      end
    end
  end

  describe "resource(@user)" do
    before :each do
      login_request
    end

    describe "PUT" do
      before(:each) do
        @user = login_request
        put :update, :id => @user.id,
                      :user => {:id => @user.id}
      end

      it "redirect to the article show action" do
        response.should redirect_to(projects_url)
      end
    end

  end
end
