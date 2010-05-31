require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Admin::UsersController do

  render_views

  describe 'with admin user' do
    before do
      login_admin
    end

    describe 'index' do
      before do
        get :index
      end
      it { response.should be_success }
      it 'should assigns all users' do
        assigns(:users).should == User.all
      end
    end

    describe 'destroy' do
      before do
        delete :destroy, :id => User.make.id
      end

      it { response.should redirect_to(admin_users_url) }
    end

    describe 'show' do
      before do
        get :show, :id => User.first.id
      end

      it { response.should be_success }
    end

    describe 'update_all' do
      before do
        put :update_all, :user_admin => {User.make.id => "1"}
      end
      it { response.should redirect_to(admin_users_url) }
      it { flash[:notice].should == 'All users updated' }
    end
  end
end
